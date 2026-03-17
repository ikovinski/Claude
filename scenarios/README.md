# Scenarios

Multi-agent workflows. A scenario orchestrates multiple agents in sequence with defined phases.

| Scenario | Command | Agents | Phases |
|----------|---------|--------|--------|
| `feature-development` | `/feature` → `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr` | Research Lead, Codebase Researcher, Design Architect, Test Strategist, Devil's Advocate, Phase Planner, Implement Lead, Code Writer, Security Reviewer, Quality Reviewer, Design Reviewer, Quality Gate | Research, Design, Plan, Implement (×N phases), Docs, PR |
| `documentation-suite` | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer | Collect, Analyze, Write, Cross-Review, Finalize |
