# /architecture-docs

High-level architecture documentation. Confluence-compatible Markdown.

## Agent
Architecture Doc Collector

## Usage

```bash
/architecture-docs                    # System profile
/architecture-docs --integration X    # Single integration
/architecture-docs --scan             # Discover integrations
```

## Output

```
docs/architecture/
├── system-profile.md
└── integrations/
    └── {category}/{name}.md
```

## Discovery (--scan)

```bash
grep -r "GuzzleHttp\|HttpClient" src/
grep -r "messenger.transport" config/
grep -E "(sdk|client)" composer.json
```

## Format

Confluence-compatible:
- Tables for structured data
- Mermaid flowcharts/sequences
- Compact templates
