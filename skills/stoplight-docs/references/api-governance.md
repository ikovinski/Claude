# API Governance Reference

Reference for enforcing API governance rules when writing Stoplight documentation.
Based on Stoplight API Best Practices documentation.

## Style Guide Enforcement with Spectral

Spectral — open-source linter for OpenAPI descriptions. Rules defined in `.spectral.yaml`.

### Where to run

- **Design-time**: Stoplight Studio, VS Code, JetBrains
- **CI/CD**: GitHub Actions on pull requests
- **Overrides**: Legacy API exceptions via config

### Example .spectral.yaml

```yaml
extends: ["spectral:oas"]
rules:
  paths-kebab-case:
    description: Paths must use kebab-case
    given: "$.paths[*]~"
    then:
      function: pattern
      functionOptions:
        match: "^(/[a-z][a-z0-9-]*(/\\{[a-zA-Z][a-zA-Z0-9]*\\})?)+$"

  operation-operationId:
    description: Every operation must have an operationId
    given: "$.paths[*][get,post,put,patch,delete]"
    then:
      field: operationId
      function: truthy

  operation-tags:
    description: Every operation must have tags
    given: "$.paths[*][get,post,put,patch,delete]"
    then:
      field: tags
      function: truthy

  no-trailing-slash:
    description: No trailing slashes on paths
    given: "$.paths[*]~"
    then:
      function: pattern
      functionOptions:
        notMatch: "/$"
```

### Public Style Guides (Spectral rulesets)

Companies publishing their API style guides:
- **Adidas** — naming, versioning, error format
- **Azure** — comprehensive REST API guidelines
- **Box** — authentication, pagination patterns
- **DigitalOcean** — resource naming, response format

## Design Review Approaches

| Approach | When to use |
|----------|-------------|
| **Manual** | Complex API design decisions, breaking changes |
| **Automated** | Naming conventions, required fields, format checks |
| **Hybrid** (recommended) | Automation for mechanics + human review for design quality |

## Security Checklist

Apply when documenting security schemes:

- [ ] HTTPS only (HTTP allowed only for localhost)
- [ ] OAuth 2.0 or API Keys documented in securitySchemes
- [ ] No HTTP Basic Auth
- [ ] UUID for identifiers (not sequential integers)
- [ ] Input validation requirements documented
- [ ] Rate limiting described (headers: X-RateLimit-Limit, X-RateLimit-Remaining)
- [ ] TLS/SSL requirements stated
- [ ] RBAC roles and permissions documented

## Authentication Documentation Template

```markdown
# Authentication

<!-- theme: info -->
> All API requests require authentication via Bearer token or API key.

## Bearer Token (OAuth 2.0)

<!--
type: tab
title: cURL
-->
` ` `bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.example.com/users
` ` `
<!--
type: tab
title: Python
-->
` ` `python
headers = {"Authorization": "Bearer YOUR_TOKEN"}
response = requests.get("https://api.example.com/users", headers=headers)
` ` `
<!-- type: tab-end -->

## API Key

Pass your API key in the `X-API-Key` header:
` ` `bash
curl -H "X-API-Key: YOUR_KEY" https://api.example.com/users
` ` `

<!-- theme: warning -->
> Never share API keys in client-side code or public repositories.
```

## Error Handling Documentation Template

```markdown
# Error Handling

All errors follow a consistent format:

` ` `json
{
  "code": "RESOURCE_NOT_FOUND",
  "message": "User with ID 123 not found",
  "details": [
    {
      "field": "userId",
      "reason": "No resource exists with this identifier"
    }
  ]
}
` ` `

<!-- title: Common Error Codes -->
| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | VALIDATION_ERROR | Request body validation failed |
| 401 | UNAUTHORIZED | Missing or invalid authentication |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | RESOURCE_NOT_FOUND | Requested resource does not exist |
| 409 | CONFLICT | Resource state conflict |
| 422 | UNPROCESSABLE_ENTITY | Semantic validation error |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Unexpected server error |
```

## Pagination Documentation Template

```markdown
# Pagination

All list endpoints support cursor-based pagination.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pageSize` | integer | 20 | Items per page (max 100) |
| `cursor` | string | — | Cursor from previous response |

## Response

` ` `json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTAwfQ==",
    "hasMore": true,
    "totalCount": 250
  }
}
` ` `

<!-- theme: info -->
> Use the `nextCursor` value from the response as the `cursor` parameter in your next request.
```

## Documentation Quality Checklist

Use when reviewing documentation for Stoplight compatibility:

### Articles
- [ ] H1 title is action-oriented
- [ ] Overview section present (1-2 sentences)
- [ ] SMD callouts used for warnings/tips (not plain bold text)
- [ ] Code examples use tabs for multiple languages
- [ ] All code examples are copy-pasteable
- [ ] Links to related articles included
- [ ] Getting Started guide takes < 5 min

### OpenAPI Spec
- [ ] info.title, info.description, info.version present
- [ ] servers defined with production URL
- [ ] All paths: kebab-case, plural nouns, no trailing slash
- [ ] All params: camelCase
- [ ] Every operation: summary, description, operationId, tags
- [ ] tags array has descriptions
- [ ] securitySchemes defined
- [ ] Standard error schema used across all endpoints
- [ ] Response examples provided for every endpoint
- [ ] Reusable components used ($ref) instead of duplication

### Project
- [ ] toc.json defines sidebar navigation
- [ ] Getting Started is first in navigation
- [ ] Authentication guide exists
- [ ] Error handling guide exists
- [ ] Files organized: docs/ for articles, reference/ for specs
