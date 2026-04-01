# Scenarios

Multi-agent workflows. A scenario orchestrates multiple agents in sequence with defined phases.

| Scenario | Command | Agents | Phases |
|----------|---------|--------|--------|
| `feature-development` | `/feature` → `/refine` (opt) → `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr` | Task Refiner, Research Lead, Codebase Researcher, Design Architect, Test Strategist, Devil's Advocate, Phase Planner, Implement Lead, Code Writer, Security Reviewer, Quality Reviewer, Design Reviewer, Quality Gate | Refine (opt), Research, Design, Plan, Implement (×N phases), Docs, PR |
| `documentation-suite` | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer | Collect, Analyze, Write, Cross-Review, Finalize |
| `sentry-triage` | `/sentry-triage` → `/feature --from ...` | Sentry Triager → Feature Development agents | Triage, then Feature Development flow |
