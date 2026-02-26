# API Documentation Template

## Purpose
Document API endpoints for developers from other teams who need to integrate.

## Freshness Metadata

All generated API docs MUST include freshness header:

```yaml
# Add to top of openapi.yaml
info:
  title: API Name
  version: 1.0.0
  x-generated-at: "YYYY-MM-DD"
  x-validation-status: "passed"  # passed | stale | failed
```

## Audience
Technical developers who:
- Need to call your API
- Don't know your internal domain
- Want working examples immediately

## Output Location

```
{project}/docs/references/
├── openapi.yaml          # Main API spec
├── schemas/              # Reusable schemas
└── examples/             # Request/response examples
```

## Process

1. **Scan code** — Controllers, DTOs, validation rules
2. **Generate OpenAPI** — `docs/references/openapi.yaml`
3. **Add Mermaid diagrams** — sequence diagrams for complex flows
4. **Write guides** — `docs/guides/` for how-to documentation

---

## Mermaid for API Flows

Always include sequence diagram for non-trivial endpoints:

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Auth
    participant DB
    participant Queue

    Client->>API: POST /api/v1/workouts
    API->>Auth: Validate token
    Auth-->>API: User context
    API->>DB: INSERT workout
    DB-->>API: workout_id
    API->>Queue: WorkoutCreated event
    API-->>Client: 201 {id, name, ...}
```

Use flowchart for endpoints with business logic:

```mermaid
flowchart TD
    A[POST /workouts] --> B{Authenticated?}
    B -->|No| C[401 Unauthorized]
    B -->|Yes| D{Valid payload?}
    D -->|No| E[422 Validation Error]
    D -->|Yes| F[Create workout]
    F --> G{User has quota?}
    G -->|No| H[403 Quota exceeded]
    G -->|Yes| I[Save & publish event]
    I --> J[201 Created]
```

---

## OpenAPI Endpoint Template

```yaml
# Add to paths: section of openapi.yaml

/api/v1/{resource}:
  get:
    summary: Short description (< 10 words)
    description: |
      What this endpoint does and when to use it.

      **Permissions**: Required scopes or roles
      **Rate limit**: X requests per minute
      **Caching**: Response cached for X seconds
    operationId: uniqueOperationId
    tags:
      - ResourceGroup
    parameters:
      - name: param_name
        in: query  # or: path, header
        required: false
        description: What this parameter controls
        schema:
          type: string
          enum: [value1, value2]
          default: value1
        example: value1
    responses:
      '200':
        description: Success response description
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ResourceResponse'
            example:
              id: "res_abc123"
              name: "Example Resource"
              created_at: "2024-01-15T10:30:00Z"
      '400':
        $ref: '#/components/responses/BadRequest'
      '401':
        $ref: '#/components/responses/Unauthorized'
      '404':
        $ref: '#/components/responses/NotFound'
      '429':
        $ref: '#/components/responses/RateLimited'

  post:
    summary: Create new resource
    description: |
      Creates a new resource with the provided data.

      **Permissions**: `resource:write` scope required
      **Idempotency**: Use `Idempotency-Key` header for safe retries
    operationId: createResource
    tags:
      - ResourceGroup
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CreateResourceRequest'
          example:
            name: "New Resource"
            type: "standard"
            metadata:
              key: "value"
    responses:
      '201':
        description: Resource created successfully
        headers:
          Location:
            description: URL of created resource
            schema:
              type: string
              example: /api/v1/resources/res_abc123
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ResourceResponse'
      '422':
        $ref: '#/components/responses/ValidationError'
```

---

## Reusable Components Template

```yaml
# Add to components: section of openapi.yaml

components:
  schemas:
    # Request schema
    CreateResourceRequest:
      type: object
      required:
        - name
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 255
          description: Human-readable name
          example: "My Resource"
        type:
          type: string
          enum: [standard, premium]
          default: standard
          description: Resource type affects available features
        metadata:
          type: object
          additionalProperties: true
          description: Arbitrary key-value pairs

    # Response schema
    ResourceResponse:
      type: object
      properties:
        id:
          type: string
          pattern: '^res_[a-zA-Z0-9]{10}$'
          description: Unique resource identifier
          example: res_abc123defg
        name:
          type: string
          example: "My Resource"
        type:
          type: string
          enum: [standard, premium]
        status:
          type: string
          enum: [active, inactive, deleted]
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time

    # Error schema
    Error:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
              example: validation_error
            message:
              type: string
              example: "Invalid input data"
            details:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                  message:
                    type: string

  responses:
    BadRequest:
      description: Invalid request format
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: bad_request
              message: "Invalid JSON in request body"

    Unauthorized:
      description: Missing or invalid authentication
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: unauthorized
              message: "Invalid or expired access token"

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: not_found
              message: "Resource not found"

    ValidationError:
      description: Request validation failed
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: validation_error
              message: "Validation failed"
              details:
                - field: name
                  message: "Name is required"

    RateLimited:
      description: Too many requests
      headers:
        Retry-After:
          description: Seconds until rate limit resets
          schema:
            type: integer
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: rate_limited
              message: "Rate limit exceeded. Retry after 60 seconds"

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT token obtained from `/auth/token` endpoint.
        Include in header: `Authorization: Bearer {token}`
```

---

## Markdown Guide Template (for Stoplight)

```markdown
---
stoplight-id: guide-resource-api
---

# Resource API Guide

Quick start guide for integrating with the Resource API.

## Authentication

All requests require a Bearer token:

\`\`\`http
GET /api/v1/resources HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
\`\`\`

Get a token from the Auth service: [Authentication Guide](./authentication.md)

## Quick Start

### 1. Create a Resource

\`\`\`http
POST /api/v1/resources HTTP/1.1
Host: api.example.com
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "My First Resource",
  "type": "standard"
}
\`\`\`

**Response** (201 Created):
\`\`\`json
{
  "id": "res_abc123defg",
  "name": "My First Resource",
  "type": "standard",
  "status": "active",
  "created_at": "2024-01-15T10:30:00Z"
}
\`\`\`

### 2. Get Resource Details

\`\`\`http
GET /api/v1/resources/res_abc123defg HTTP/1.1
Host: api.example.com
Authorization: Bearer {token}
\`\`\`

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Invalid request | Check request format |
| 401 | Auth failed | Refresh token |
| 404 | Not found | Verify resource ID |
| 422 | Validation error | Check `details` array |
| 429 | Rate limited | Wait and retry |

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| GET requests | 100/min |
| POST/PUT/DELETE | 30/min |

## Webhooks

Subscribe to events via [Webhook API](./webhooks.md):
- `resource.created`
- `resource.updated`
- `resource.deleted`
```

---

## Checklist

Before publishing API docs:

- [ ] All endpoints have working examples
- [ ] Request AND response shown for each endpoint
- [ ] Error responses documented (400, 401, 404, 422)
- [ ] Authentication requirements clear
- [ ] Rate limits documented
- [ ] Required vs optional parameters marked
- [ ] No internal implementation details exposed
- [ ] Tested examples actually work
