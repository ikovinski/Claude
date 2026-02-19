# Docs

## What is it
Документація, гайди та довідкові матеріали для AI agents system.

## Structure

```
docs/
├── how-it-works/                    # Пояснення як працює система
│   ├── how-scenarios-work.md        # Multi-agent workflows
│   ├── plan-vs-ai-debug-prompt.md   # Порівняння команд
│   ├── doc-agents-comparison.md     # Tech Writer vs Arch Doc Collector vs Codebase Doc Collector
│   └── doc-agents-cooperation.md    # Codebase Doc Collector + Tech Writer protocol
├── plans/                           # Згенеровані плани (output від /plan)
├── HOW-TO-USE.md                    # Детальний гайд
├── skills-integration-summary.md    # Skills + agents інтеграція
├── skills-mapping.md                # Agents → skills маппінг
└── skills-reorganization-summary.md # Історія реорганізації
```

## How It Works

| Document | Description |
|----------|-------------|
| [how-scenarios-work.md](how-it-works/how-scenarios-work.md) | Multi-agent workflows, phases, decision points |
| [plan-vs-ai-debug-prompt.md](how-it-works/plan-vs-ai-debug-prompt.md) | Різниця між /plan та /ai-debug --prompt |
| [doc-agents-comparison.md](how-it-works/doc-agents-comparison.md) | Technical Writer vs Architecture Doc Collector vs Codebase Doc Collector |
| [doc-agents-cooperation.md](how-it-works/doc-agents-cooperation.md) | Cache protocol: Codebase Doc Collector → Technical Writer |

## Generated Plans

Команда `/plan` зберігає плани у `docs/plans/`:

```
docs/plans/
├── 001.new-feature.md
├── 002.next-feature.md
└── ...
```

**Naming**: `{version}.{slug}.md`

## Integration Guides

| Document | Description |
|----------|-------------|
| [skills-integration-summary.md](skills-integration-summary.md) | Як skills інтегруються з agents/scenarios |
| [skills-mapping.md](skills-mapping.md) | Маппінг agents → skills |

## Quick Reference

| Topic | Go to |
|-------|-------|
| Повний гайд | [HOW-TO-USE.md](HOW-TO-USE.md) |
| Як працюють scenarios | [how-scenarios-work.md](how-it-works/how-scenarios-work.md) |
| /plan vs /ai-debug | [plan-vs-ai-debug-prompt.md](how-it-works/plan-vs-ai-debug-prompt.md) |
| Doc agents порівняння | [documentation-agents-comparison.md](how-it-works/documentation-agents-comparison.md) |
| Doc agents кооперація | [doc-agents-cooperation.md](how-it-works/doc-agents-cooperation.md) |
| Skills система | [../skills/README.md](../skills/README.md) |

## Coming Soon

- [ ] how-agents-work.md — Agent biases, loading, output formats
- [ ] how-skills-work.md — Universal vs project skills, auto-loading
- [ ] customization-guide.md — Creating custom agents/skills
- [ ] troubleshooting.md — Common issues and solutions
