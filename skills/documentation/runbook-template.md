# Runbook Template

## Purpose
Document operational procedures for service management, troubleshooting, and incident response.

## Freshness Metadata

Runbooks are CRITICAL for incident response. Staleness = risk.

| Staleness | Risk Level | Action |
|-----------|------------|--------|
| < 30 days | Low | OK |
| 30-60 days | Medium | Review recommended |
| > 60 days | High | Must update before next on-call rotation |

## Audience
- **Ops/SRE**: Day-to-day operations
- **On-call engineers**: Incident response
- **Developers**: Understanding production environment

---

## Template

```markdown
---
stoplight-id: runbook-{service-name}
last_updated: YYYY-MM-DD
last_validated: YYYY-MM-DD
validation_status: tested  # tested | needs-review | outdated
---

# Runbook: {Service Name}

## Service Overview

| Aspect | Value |
|--------|-------|
| **Description** | {One sentence description} |
| **Last Updated** | YYYY-MM-DD |
| **Last Validated** | YYYY-MM-DD |
| **Repository** | {github link} |
| **Tech Stack** | {e.g., PHP 8.3, Symfony 6.4} |
| **Owner Team** | {team name} |
| **On-call Rotation** | {PagerDuty link or schedule} |

### Infrastructure

| Component | Details |
|-----------|---------|
| **Hosting** | {e.g., Kubernetes cluster `prod-main`} |
| **Database** | {e.g., MySQL 8.0 on RDS `prod-workout-db`} |
| **Cache** | {e.g., Redis 7.x on ElastiCache} |
| **Queue** | {e.g., RabbitMQ on CloudAMQP} |
| **CDN** | {e.g., CloudFront distribution `XXXX`} |

### Dependencies

| Service | Purpose | Critical? |
|---------|---------|-----------|
| {Service A} | {What we use it for} | Yes/No |
| {Service B} | {What we use it for} | Yes/No |

---

## Health Checks

### Liveness Probe

```bash
curl -s https://{service}.internal/health/live
# Expected: 200 OK
```

### Readiness Probe

```bash
curl -s https://{service}.internal/health/ready
# Expected: 200 OK with JSON showing all deps healthy
```

```json
{
  "status": "healthy",
  "checks": {
    "database": "ok",
    "redis": "ok",
    "rabbitmq": "ok"
  }
}
```

### Key Metrics

| Metric | Normal Range | Alert Threshold |
|--------|--------------|-----------------|
| Response time P95 | < 200ms | > 500ms |
| Error rate | < 0.1% | > 1% |
| CPU usage | < 50% | > 80% |
| Memory usage | < 70% | > 85% |
| Queue depth | < 1000 | > 5000 |

**Dashboard**: [Link to Grafana/Datadog dashboard]

---

## Common Operations

### Deploy New Version

```bash
# 1. Check current version
kubectl get deployment {service} -o jsonpath='{.spec.template.spec.containers[0].image}'

# 2. Deploy (via CI/CD)
# Trigger: merge to main branch
# Pipeline: {link to CI/CD}

# 3. Verify deployment
kubectl rollout status deployment/{service}
kubectl get pods -l app={service}
```

### Rollback

```bash
# Quick rollback to previous version
kubectl rollout undo deployment/{service}

# Rollback to specific revision
kubectl rollout history deployment/{service}
kubectl rollout undo deployment/{service} --to-revision={N}

# Verify
kubectl rollout status deployment/{service}
```

### Scale Service

```bash
# Scale up
kubectl scale deployment/{service} --replicas=5

# Scale down
kubectl scale deployment/{service} --replicas=2

# Check current replicas
kubectl get deployment/{service}
```

### Database Migration

```bash
# 1. Check pending migrations
kubectl exec -it {service-pod} -- php bin/console doctrine:migrations:status

# 2. Run migrations
kubectl exec -it {service-pod} -- php bin/console doctrine:migrations:migrate --no-interaction

# 3. Verify
kubectl exec -it {service-pod} -- php bin/console doctrine:migrations:status
```

### Clear Cache

```bash
# Application cache
kubectl exec -it {service-pod} -- php bin/console cache:clear

# Redis cache
redis-cli -h {redis-host} FLUSHDB

# OPcache (restart PHP-FPM)
kubectl rollout restart deployment/{service}
```

---

## Troubleshooting

### High Response Time

**Symptoms**: P95 latency > 500ms, alerts firing

**Diagnosis**:

```bash
# 1. Check if it's across all pods
kubectl top pods -l app={service}

# 2. Check database slow queries (last 10 minutes)
# Datadog query:
service:{service} @duration:>1000ms

# 3. Check external dependency latency
curl -w "@curl-format.txt" -s https://{dependency}/health

# 4. Check N+1 queries
kubectl logs -l app={service} --since=5m | grep "doctrine.query" | sort | uniq -c | sort -rn | head
```

**Resolution**:

1. If single pod: restart that pod
   ```bash
   kubectl delete pod {pod-name}
   ```

2. If database: check slow query log, add missing indexes

3. If external dependency: enable circuit breaker, increase timeout

4. If N+1: identify and fix in code, deploy hotfix

### Memory Issues (OOM)

**Symptoms**: Pods restarting, OOMKilled status

**Diagnosis**:

```bash
# Check pod status
kubectl describe pod {pod-name} | grep -A5 "Last State"

# Check memory usage over time
# Grafana query: container_memory_usage_bytes{pod=~"{service}.*"}
```

**Resolution**:

1. Increase memory limit (temporary):
   ```bash
   kubectl set resources deployment/{service} --limits=memory=1Gi
   ```

2. Find memory leak (long-term):
   - Enable memory profiling
   - Check for unbounded arrays
   - Review recent deployments

### Queue Backlog

**Symptoms**: Messages piling up, processing delayed

**Diagnosis**:

```bash
# Check queue depth
rabbitmqctl list_queues name messages

# Check consumer status
kubectl get pods -l app={service}-consumer

# Check for failed messages
rabbitmqctl list_queues name messages_unacknowledged
```

**Resolution**:

1. Scale consumers:
   ```bash
   kubectl scale deployment/{service}-consumer --replicas=5
   ```

2. Check for poison messages:
   ```bash
   # View dead letter queue
   rabbitmqctl list_queues | grep dlq
   ```

3. If poison message: remove from DLQ, fix handler, redeploy

### Database Connection Exhaustion

**Symptoms**: "Too many connections" errors

**Diagnosis**:

```bash
# Check connection count
mysql -h {host} -e "SHOW STATUS LIKE 'Threads_connected';"

# Check max connections
mysql -h {host} -e "SHOW VARIABLES LIKE 'max_connections';"

# Find connection sources
mysql -h {host} -e "SELECT user, host, COUNT(*) FROM information_schema.processlist GROUP BY user, host;"
```

**Resolution**:

1. Kill idle connections:
   ```sql
   -- Find sleeping connections > 5 minutes
   SELECT id FROM information_schema.processlist
   WHERE command = 'Sleep' AND time > 300;

   -- Kill them
   KILL {id};
   ```

2. Scale down replicas temporarily

3. Review connection pool settings

---

## Incident Response

### Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| SEV1 | Service down | 15 minutes | Complete outage |
| SEV2 | Degraded | 30 minutes | High error rate |
| SEV3 | Minor issue | 4 hours | Single feature broken |

### Incident Procedure

1. **Acknowledge** alert in PagerDuty
2. **Assess** severity using health checks
3. **Communicate** in #incidents Slack channel
4. **Mitigate** using runbook procedures
5. **Escalate** if not resolved in 30 minutes
6. **Document** in incident report

### Escalation Contacts

| Level | Contact | When |
|-------|---------|------|
| L1 | On-call engineer | First responder |
| L2 | Team lead: @{name} | 30 min no resolution |
| L3 | Platform team: @{name} | Infrastructure issue |

---

## Maintenance Windows

### Scheduled Maintenance

| Day | Time (UTC) | Type |
|-----|------------|------|
| Sunday | 02:00-04:00 | Database maintenance |
| Monthly (1st) | 03:00-05:00 | Major upgrades |

### Maintenance Procedure

```bash
# 1. Enable maintenance mode
kubectl set env deployment/{service} MAINTENANCE_MODE=true

# 2. Drain connections (wait 60s)
sleep 60

# 3. Perform maintenance
# ...

# 4. Disable maintenance mode
kubectl set env deployment/{service} MAINTENANCE_MODE=false

# 5. Verify health
curl https://{service}/health/ready
```

---

## Logs & Monitoring

### Log Locations

| Log Type | Location |
|----------|----------|
| Application | Datadog: `service:{service}` |
| Access logs | Datadog: `source:nginx service:{service}` |
| Error logs | Datadog: `service:{service} status:error` |

### Useful Queries

```
# Errors in last hour
service:{service} status:error

# Slow requests
service:{service} @duration:>1000ms

# Specific user
service:{service} @user_id:{id}

# Specific endpoint
service:{service} @http.url:*workout*
```

### Alerts

| Alert | Condition | Action |
|-------|-----------|--------|
| High Error Rate | > 1% for 5 min | Check logs, recent deploys |
| High Latency | P95 > 500ms for 5 min | Check DB, dependencies |
| Pod Restarts | > 3 in 10 min | Check OOM, logs |

---

## Disaster Recovery

### Backup Schedule

| Data | Frequency | Retention | Location |
|------|-----------|-----------|----------|
| Database | Daily | 30 days | S3 `backups/{service}/db/` |
| Redis | Hourly | 24 hours | S3 `backups/{service}/redis/` |

### Restore Procedure

```bash
# 1. Stop the service
kubectl scale deployment/{service} --replicas=0

# 2. Restore database
aws s3 cp s3://backups/{service}/db/{date}.sql.gz - | gunzip | mysql -h {host} {database}

# 3. Verify data
mysql -h {host} {database} -e "SELECT COUNT(*) FROM {main_table}"

# 4. Restart service
kubectl scale deployment/{service} --replicas=3
```

---

## Appendix

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | DB connection string | `mysql://user:pass@host/db` |
| `REDIS_URL` | Redis connection | `redis://host:6379` |
| `LOG_LEVEL` | Logging verbosity | `info` |

### Useful Commands Cheatsheet

```bash
# Get pod logs
kubectl logs -f -l app={service} --all-containers

# Exec into pod
kubectl exec -it {pod} -- /bin/sh

# Port forward for debugging
kubectl port-forward svc/{service} 8080:80

# Check resource usage
kubectl top pods -l app={service}
```
```

---

## Checklist

Before publishing runbook:

- [ ] All commands tested and working
- [ ] Health check URLs correct
- [ ] Escalation contacts current
- [ ] Dashboard links working
- [ ] Backup/restore procedure tested
- [ ] Common issues cover 80% of incidents
- [ ] No secrets or credentials in runbook
