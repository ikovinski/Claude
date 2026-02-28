# /dev Workflow — Flow Diagrams

Візуалізація повного pipeline, Agent Teams, артефактів та зворотних петель.

---

## 1. Main Pipeline Overview

```mermaid
flowchart TB
    START(("/dev 'Add feature'")) --> R

    subgraph R["1. RESEARCH"]
        direction TB
        R_DESC["Що є зараз? (AS-IS)"]
        R_TEAM["👥 Team: 3 agents"]
        R_OUT["📁 .workflows/research/ (5 files)"]
    end

    R --> D

    subgraph D["2. DESIGN"]
        direction TB
        D_DESC["Як це має працювати?"]
        D_TEAM["👥 Team: 2 agents"]
        D_OUT["📁 .workflows/design/"]
    end

    D --> QG1{{"🚦 QUALITY GATE\nHuman Approval"}}
    QG1 -->|"❌ rejected"| D
    QG1 -->|"✅ approved"| P

    subgraph P["3. PLAN"]
        direction TB
        P_DESC["В якому порядку робити?"]
        P_TEAM["👤 Single: planner"]
        P_OUT["📁 .workflows/plan/{slug}/"]
    end

    P --> I

    subgraph I["4. IMPLEMENT"]
        direction TB
        I_DESC["Пишемо код (TDD)"]
        I_TEAM["👥 Team: 2 agents"]
        I_OUT["📁 Code + PROGRESS.md"]
        I_LOOP["🔄 developer ↔ reviewer loop"]
    end

    I -->|"REPLAN-NEEDED.md"| P
    I --> REV

    subgraph REV["5. REVIEW"]
        direction TB
        REV_DESC["Фінальна перевірка"]
        REV_TEAM["👥 Team: 3 agents"]
        REV_OUT["📁 .workflows/review/{slug}/"]
    end

    REV --> QG2{{"🚦 Blocking issues?"}}
    QG2 -->|"🔴 blocking"| I
    QG2 -->|"🟢 clear"| DOC

    subgraph DOC["6. DOCUMENT"]
        direction TB
        DOC_DESC["Документуємо фічу"]
        DOC_TEAM["👥 Team: 3 agents"]
        DOC_OUT["📁 .workflows/document/ + docs/"]
    end

    DOC --> PR

    subgraph PR["7. PR"]
        direction TB
        PR_DESC["Branch + Commits + Docs"]
        PR_TEAM["👤 Single: bash/gh"]
        PR_OUT["📁 .workflows/pr/PR.md"]
    end

    PR --> QG3{{"🚦 Create PR?\n(default: no)"}}
    QG3 -->|"✅ user approves"| GH["🔗 GitHub PR"]
    QG3 -->|"❌ no"| BRANCH["🌿 Branch only"]

    style R fill:#e8f4fd,stroke:#1976d2
    style D fill:#fff3e0,stroke:#f57c00
    style P fill:#f3e5f5,stroke:#7b1fa2
    style I fill:#e8f5e9,stroke:#388e3c
    style REV fill:#fce4ec,stroke:#c62828
    style DOC fill:#e1f5fe,stroke:#0277bd
    style PR fill:#f5f5f5,stroke:#616161
    style QG1 fill:#fff9c4,stroke:#f9a825
    style QG2 fill:#fff9c4,stroke:#f9a825
    style QG3 fill:#fff9c4,stroke:#f9a825
```

---

## 2. Agent Teams per Step

```mermaid
flowchart LR
    subgraph STEP1["Step 1: Research"]
        direction TB
        R_LEAD["🎯 researcher\n(Lead, opus)"]
        R_CODE["📦 codebase-doc-collector\n(code-scanner, sonnet)"]
        R_ARCH["🏗️ architecture-doc-collector\n(arch-scanner, sonnet)"]
        R_LEAD -->|"decompose\ntask"| R_CODE
        R_LEAD -->|"decompose\ntask"| R_ARCH
        R_CODE -->|"results"| R_LEAD
        R_ARCH -->|"results"| R_LEAD
    end

    subgraph STEP2["Step 2: Design"]
        direction TB
        D_LEAD["🎯 architecture-advisor\n(Lead, opus)"]
        D_WRITER["📝 technical-writer\n(contract-writer, sonnet)"]
        D_LEAD -->|"design\ncontext"| D_WRITER
        D_WRITER -->|"api-contracts"| D_LEAD
    end

    subgraph STEP3["Step 3: Plan"]
        direction TB
        P_AGENT["📋 planner\n(Single, sonnet)"]
    end

    subgraph STEP4["Step 4: Implement"]
        direction TB
        I_DEV["💻 tdd-guide\n(developer, sonnet)"]
        I_REV["🔍 code-reviewer\n(reviewer, sonnet)"]
        I_DEV -->|"ready for\nreview"| I_REV
        I_REV -->|"✅ approved"| I_NEXT["Next Phase"]
        I_REV -->|"❌ fix needed"| I_DEV
    end

    subgraph STEP5["Step 5: Review"]
        direction TB
        REV_LEAD["🎯 Team Lead\n(opus)"]
        REV_Q["📊 code-reviewer\n(quality, sonnet)"]
        REV_S["🔒 security-reviewer\n(security, sonnet)"]
        REV_LEAD -->|"parallel"| REV_Q
        REV_LEAD -->|"parallel"| REV_S
        REV_Q -->|"quality\nfindings"| REV_LEAD
        REV_S -->|"security\nfindings"| REV_LEAD
    end

    subgraph STEP6["Step 6: Document"]
        direction TB
        DOC_LEAD["🎯 technical-writer\n(Lead, opus)"]
        DOC_FW["📝 technical-writer\n(feature-writer, sonnet)"]
        DOC_DS["📦 codebase-doc-collector\n(delta-scanner, sonnet)"]
        DOC_LEAD -->|"Track A"| DOC_FW
        DOC_LEAD -->|"Track B"| DOC_DS
        DOC_FW -->|"feature spec\nAPI delta\nADR"| DOC_LEAD
        DOC_DS -->|"delta\nreport"| DOC_LEAD
    end

    subgraph STEP7["Step 7: PR"]
        direction TB
        PR_AGENT["⚙️ bash / gh CLI"]
    end

    style STEP1 fill:#e8f4fd,stroke:#1976d2
    style STEP2 fill:#fff3e0,stroke:#f57c00
    style STEP3 fill:#f3e5f5,stroke:#7b1fa2
    style STEP4 fill:#e8f5e9,stroke:#388e3c
    style STEP5 fill:#fce4ec,stroke:#c62828
    style STEP6 fill:#e1f5fe,stroke:#0277bd
    style STEP7 fill:#f5f5f5,stroke:#616161
```

---

## 3. Artifact Flow Between Steps

```mermaid
flowchart LR
    subgraph RES_OUT["Research Output"]
        RES1["RESEARCH.md"]
        RES2["code-analysis.md"]
        RES3["data-model.md"]
        RES4["architecture-analysis.md"]
        RES5["test-coverage.md"]
    end

    subgraph DES_OUT["Design Output"]
        DES1["DESIGN.md"]
        DES2["diagrams.md"]
        DES3["api-contracts.md"]
        DES4["adr/*.md"]
    end

    subgraph PLN_OUT["Plan Output"]
        PLN1["001-PLAN.md"]
    end

    subgraph IMP_OUT["Implement Output"]
        IMP1["Code Files"]
        IMP2["PROGRESS.md"]
    end

    subgraph RVW_OUT["Review Output"]
        RVW1["REVIEW.md"]
    end

    subgraph DOC_OUT["Document Output"]
        DOC1["DOCS.md"]
        DOC2["feature-spec.md"]
        DOC3["api-changes.md"]
        DOC4["adr-updates.md"]
        DOC5["delta-report.md"]
    end

    subgraph PR_OUT["PR Output"]
        PR1["PR.md"]
        PR2["git branch"]
        PR3["git commits"]
    end

    RES_OUT -->|"input"| DES_OUT
    RES_OUT -->|"input"| PLN_OUT
    DES_OUT -->|"input"| PLN_OUT
    DES_OUT -->|"input"| IMP_OUT
    PLN_OUT -->|"input"| IMP_OUT
    DES_OUT -->|"compliance\ncheck"| RVW_OUT
    IMP_OUT -->|"code to\nreview"| RVW_OUT
    DES_OUT -->|"feature\noverview"| DOC_OUT
    IMP_OUT -->|"file list\n(scope)"| DOC_OUT
    RVW_OUT -->|"verdict"| DOC_OUT
    DOC_OUT -->|"docs for\nstaging"| PR_OUT
    RVW_OUT -->|"PR\ndescription"| PR_OUT
    DES_OUT -->|"summary"| PR_OUT
    PLN_OUT -->|"changes\nlist"| PR_OUT

    style RES_OUT fill:#e8f4fd,stroke:#1976d2
    style DES_OUT fill:#fff3e0,stroke:#f57c00
    style PLN_OUT fill:#f3e5f5,stroke:#7b1fa2
    style IMP_OUT fill:#e8f5e9,stroke:#388e3c
    style RVW_OUT fill:#fce4ec,stroke:#c62828
    style DOC_OUT fill:#e1f5fe,stroke:#0277bd
    style PR_OUT fill:#f5f5f5,stroke:#616161
```

---

## 4. Step Internal Flows

### 4.1 Research — 3 Phases

```mermaid
sequenceDiagram
    participant U as User
    participant L as Lead (researcher)
    participant CS as Code Scanner
    participant AS as Arch Scanner

    U->>L: /dev "Add Apple Health"

    Note over L: Phase 1: DECOMPOSE
    L->>L: Analyze task, identify research areas

    Note over L,AS: Phase 2: SCAN (parallel)
    par Code Analysis
        L->>CS: "Scan wearable services, entities, tests"
        CS->>CS: Glob + Grep + Read codebase
        CS-->>L: code-analysis.md, data-model.md, test-coverage.md
    and Architecture Analysis
        L->>AS: "Map integrations, boundaries, patterns"
        AS->>AS: Analyze architecture, draw Mermaid
        AS-->>L: architecture-analysis.md
    end

    Note over L: Phase 3: AGGREGATE
    L->>L: Cross-reference findings
    L->>L: Identify open questions
    L-->>U: RESEARCH.md + 4 detail files
```

### 4.2 Design — 4 Phases

```mermaid
sequenceDiagram
    participant U as User
    participant L as Lead (architect)
    participant W as Contract Writer

    Note over L: Phase 1: ANALYZE
    L->>L: Read all research artifacts
    L->>L: Design architecture (C4, DataFlow, Sequence)
    L->>L: Write ADR(s)

    Note over L,W: Phase 2: CONTRACTS (parallel)
    L->>W: "Write API contracts based on design"
    W->>W: Endpoints, schemas, error codes
    W-->>L: api-contracts.md

    Note over L: Phase 3: COMPILE
    L->>L: Finalize DESIGN.md + diagrams.md
    L->>L: Cross-validate contracts vs design

    Note over L,U: Phase 4: QUALITY GATE
    L-->>U: Show design for review
    U->>U: Review design artifacts

    alt Approved
        U->>L: ✅ Proceed
    else Rejected
        U->>L: ❌ Revise (feedback)
        L->>L: Update design
    end
```

### 4.3 Plan — 3 Phases

```mermaid
sequenceDiagram
    participant P as Planner

    Note over P: Phase 1: VALIDATE
    P->>P: Read research/ + design/
    P->>P: Verify artifacts complete

    Note over P: Phase 2: SYNTHESIZE
    P->>P: Identify vertical slices
    P->>P: Determine phase dependencies

    Note over P: Phase 3: PLAN
    P->>P: Create phases (each deployable)
    P->>P: Define TDD approach per phase
    P->>P: Set verification criteria
    P-->>P: 001-PLAN.md
```

### 4.4 Implement — Internal Loop (per Phase)

```mermaid
sequenceDiagram
    participant D as Developer (TDD)
    participant R as Reviewer
    participant FS as Filesystem

    loop For each Phase in PLAN.md
        Note over D: READ PHASE
        D->>FS: Read Phase N from PLAN.md + DESIGN.md

        Note over D: RED (failing tests)
        D->>D: Write failing tests
        D->>FS: Run tests → FAIL ✅

        Note over D: GREEN (implement)
        D->>D: Write minimum code to pass
        D->>FS: Run tests → PASS ✅

        Note over D: REFACTOR
        D->>D: Cleanup, naming, DRY

        Note over D,R: REVIEW
        D->>R: "Phase N ready for review"

        R->>R: Check security
        R->>R: Check quality
        R->>R: Check plan compliance
        R->>R: Check test coverage

        alt Issues Found
            R->>D: "Fix: [issues list]"
            D->>D: Fix issues
            D->>R: "Fixed, re-review"
            R->>R: Re-check
        end

        R->>D: ✅ Phase N approved
        D->>FS: Update PROGRESS.md
    end
```

### 4.5 Review — 2 Phases

```mermaid
sequenceDiagram
    participant L as Team Lead
    participant Q as Quality Reviewer
    participant S as Security Reviewer

    Note over L,S: Phase 1: REVIEW (parallel)
    par Quality Review
        L->>Q: "Review full scope: consistency, coverage, design compliance"
        Q->>Q: Cross-phase consistency
        Q->>Q: Test coverage ≥ 85%
        Q->>Q: Design compliance
        Q-->>L: Quality findings + score
    and Security Review
        L->>S: "OWASP Top 10 + PII/PHI audit"
        S->>S: Input validation
        S->>S: Auth/AuthZ checks
        S->>S: PII/PHI in logs
        S->>S: Webhook security
        S-->>L: Security findings + score
    end

    Note over L: Phase 2: COMPILE
    L->>L: Merge findings
    L->>L: Assign severity (BLK- / SUG-)
    L->>L: Calculate scores (quality: 1-10, security: 1-10)

    alt Has Blocking Issues
        L-->>L: Verdict: BLOCKED
    else No Blocking
        L-->>L: Verdict: APPROVED
    end
    L-->>L: REVIEW.md
```

### 4.6 Document — 3 Phases

```mermaid
sequenceDiagram
    participant U as User
    participant L as Lead (technical-writer)
    participant FW as Feature Writer
    participant DS as Delta Scanner

    Note over L: Phase 1: SCOPE
    L->>L: Read PROGRESS.md, REVIEW.md, DESIGN.md
    L->>L: Determine scope: APIs? ADRs? Integrations?
    L->>L: Create task assignments

    Note over L,DS: Phase 2: GENERATE (parallel)
    par Track A — Bounded Context
        L->>FW: "Feature spec + API delta + ADR finalization"
        FW->>FW: Generate feature-spec.md
        FW->>FW: Generate api-changes.md (OpenAPI snippet)
        FW->>FW: Update ADR status: Proposed → Accepted
        FW-->>L: feature-spec.md, api-changes.md, adr-updates.md
    and Track B — General Docs Delta
        L->>DS: "Scan existing docs for stale/missing/broken refs"
        DS->>DS: STALE scan (changed code, old docs)
        DS->>DS: MISSING scan (new code, no docs)
        DS->>DS: BROKEN_LINK scan
        DS->>DS: Auto-fix CODEMAPS, INDEX.md
        DS-->>L: delta-report.md + auto-fixes
    end

    Note over L: Phase 3: COMPILE
    L->>L: Cross-check consistency
    L->>L: Create DOCS.md summary

    alt > 10 stale findings
        L-->>U: Recommend /docs-suite for full review
    else Normal
        L-->>U: DOCS.md + Continue / Fix / Skip-docs
    end
```

### 4.7 PR — 5 Phases

```mermaid
sequenceDiagram
    participant CLI as bash / gh CLI
    participant U as User

    Note over CLI: Phase 1: VALIDATE
    CLI->>CLI: Check REVIEW.md exists
    CLI->>CLI: Verify no blocking issues
    CLI->>CLI: Check git status clean

    Note over CLI: Phase 2: BRANCH
    CLI->>CLI: git checkout -b feature/{slug}

    Note over CLI: Phase 3: COMMIT
    CLI->>CLI: Stage relevant files
    alt Multiple Phases (3+)
        CLI->>CLI: Per-phase commits
    else Few Phases (1-2)
        CLI->>CLI: Single commit
    end
    Note right of CLI: No Co-Authored-By!

    Note over CLI: Phase 4: PR DRAFT
    CLI->>CLI: Generate PR.md from artifacts
    CLI->>CLI: Summary ← DESIGN.md
    CLI->>CLI: Changes ← PLAN.md phases
    CLI->>CLI: Test plan ← REVIEW.md

    Note over CLI,U: Phase 5: ASK USER
    CLI->>CLI: git push -u origin feature/{slug}
    CLI->>U: "Create PR? (default: no)"
    alt User approves
        U->>CLI: "Yes"
        CLI->>CLI: gh pr create
    else Default / No
        U->>CLI: "No"
        CLI->>CLI: Branch pushed, no PR
    end
```

---

## 5. Feedback Loops

```mermaid
flowchart TB
    subgraph MAIN["Main Pipeline"]
        R["1. Research"] --> D["2. Design"]
        D --> P["3. Plan"]
        P --> I["4. Implement"]
        I --> REV["5. Review"]
        REV --> DOC["6. Document"]
        DOC --> PR["7. PR"]
    end

    subgraph LOOPS["Feedback Loops"]
        direction TB

        L1["🔄 Design Rejection\nQuality Gate → back to Design"]
        L2["🔄 REPLAN\nImplement → back to Plan\n(REPLAN-NEEDED.md)"]
        L3["🔄 Blocking Issues\nReview → back to Implement"]
        L4["🔄 Internal Review\ndeveloper ↔ reviewer\n(within Implement)"]
        L5["🔄 CODE-ISSUE\nDocument → user decides\n(CODE-ISSUE.md)"]
    end

    D -.->|"❌ rejected"| D
    I -.->|"REPLAN-NEEDED.md"| P
    REV -.->|"🔴 blocking"| I
    I -.->|"🔍 review loop"| I
    DOC -.->|"CODE-ISSUE.md"| I

    style MAIN fill:#f9f9f9,stroke:#333
    style LOOPS fill:#fff9c4,stroke:#f9a825
    style L1 fill:#fff3e0
    style L2 fill:#f3e5f5
    style L3 fill:#fce4ec
    style L4 fill:#e8f5e9
    style L5 fill:#e1f5fe
```

---

## 6. State Machine

```mermaid
stateDiagram-v2
    [*] --> Research: /dev "task"

    Research --> Design: research completed
    Design --> AwaitingApproval: design ready

    state design_gate <<choice>>
    AwaitingApproval --> design_gate: human reviews
    design_gate --> Design: rejected
    design_gate --> Plan: approved

    Plan --> Implement: plan ready
    Implement --> Implement: developer ↔ reviewer loop

    state replan_check <<choice>>
    Implement --> replan_check: phase issue
    replan_check --> Plan: REPLAN-NEEDED.md
    replan_check --> Review: all phases done

    state blocking_check <<choice>>
    Review --> blocking_check: review done
    blocking_check --> Implement: blocking issues
    blocking_check --> Document: no blocking

    Document --> Document: Track A ∥ Track B
    state doc_check <<choice>>
    Document --> doc_check: docs generated
    doc_check --> Implement: CODE-ISSUE.md
    doc_check --> PR: docs ready

    state pr_check <<choice>>
    PR --> pr_check: branch pushed
    pr_check --> PRCreated: user approves
    pr_check --> BranchOnly: default (no PR)

    PRCreated --> [*]
    BranchOnly --> [*]
```

---

## 7. Complete Pipeline — Detailed View

```mermaid
flowchart TB
    START(("/dev 'task'")) ==> R

    subgraph R["1. RESEARCH — AS-IS Analysis"]
        direction LR
        R1["🎯 researcher<br/>(Lead)"] ==>|"decompose"| R2["📦 code-scanner<br/>📦 arch-scanner"]
        R2 ==>|"aggregate"| R3["📁 research/<br/>5 files"]
    end

    R ==>|"research/*"| D

    subgraph D["2. DESIGN — Technical Design"]
        direction LR
        D1["🎯 architect<br/>(Lead)"] ==>|"contracts"| D2["📝 contract-writer"]
        D2 ==>|"compile"| D3["📁 design/<br/>DESIGN + diagrams<br/>+ contracts + ADR"]
    end

    D ==> QG1{{"🚦 Quality Gate"}}
    QG1 -.->|"❌"| D
    QG1 ==>|"✅"| P

    subgraph P["3. PLAN — Phase Breakdown"]
        direction LR
        P1["📋 planner"] ==> P2["📁 plan/{slug}/<br/>001-PLAN.md"]
    end

    P ==>|"PLAN.md"| I

    subgraph I["4. IMPLEMENT — TDD + Review Loop"]
        direction LR
        I1["💻 developer<br/>(TDD)"] ==>|"review"| I2["🔍 reviewer"]
        I2 -.->|"❌ fix"| I1
        I2 ==>|"✅"| I3["📁 implement/<br/>PROGRESS.md<br/>+ Code"]
    end

    I -.->|"REPLAN"| P
    I ==>|"code"| REV

    subgraph REV["5. REVIEW — Full Scope"]
        direction LR
        REV1["📊 quality<br/>🔒 security"] ==>|"compile"| REV2["📁 review/{slug}/<br/>REVIEW.md"]
    end

    REV ==> QG2{{"🚦 Blocking?"}}
    QG2 -.->|"🔴"| I
    QG2 ==>|"🟢"| DOC

    subgraph DOC["6. DOCUMENT — Feature Docs + Delta"]
        direction LR
        DOC1["🎯 Lead<br/>(technical-writer)"] ==>|"parallel"| DOC2["📝 feature-writer<br/>📦 delta-scanner"]
        DOC2 ==>|"compile"| DOC3["📁 document/<br/>DOCS.md + specs<br/>+ docs/ updates"]
    end

    DOC ==> PR

    subgraph PR["7. PR — Branch + Commits + Docs"]
        direction LR
        PR1["⚙️ git + gh"] ==> PR2["📁 pr/PR.md<br/>🌿 branch<br/>📦 commits"]
    end

    PR ==> QG3{{"🚦 Create PR?"}}
    QG3 ==>|"✅ yes"| GH(["🔗 GitHub PR"])
    QG3 ==>|"❌ default"| DONE(["🌿 Branch pushed"])

    style R fill:#e8f4fd,stroke:#1976d2,stroke-width:2px
    style D fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style P fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style I fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style REV fill:#fce4ec,stroke:#c62828,stroke-width:2px
    style DOC fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
    style PR fill:#f5f5f5,stroke:#616161,stroke-width:2px
    style QG1 fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style QG2 fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style QG3 fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style GH fill:#dcedc8,stroke:#689f38,stroke-width:2px
    style DONE fill:#dcedc8,stroke:#689f38,stroke-width:2px
```

---

## 8. `/dev --status` View

Visual representation of the status table that `/dev --status` outputs:

```
┌────────────┬────────────┬───────────────┬────────────────────────────────┐
│   Step     │   Status   │   Agents      │   Output                       │
├────────────┼────────────┼───────────────┼────────────────────────────────┤
│ Research   │ ✅ done    │ 3 agents      │ .workflows/research/ (5 files) │
│ Design     │ ✅ done    │ 2 agents      │ .workflows/design/ (4+ files)  │
│ Plan       │ ✅ done    │ 1 agent       │ .workflows/plan/{slug}/        │
│ Implement  │ 🔄 3/4    │ 2 agents      │ Code + PROGRESS.md             │
│ Review     │ ⏳ pending │ 3 agents      │ —                              │
│ Document   │ ⏳ pending │ 3 agents      │ —                              │
│ PR         │ ⏳ pending │ bash/gh       │ —                              │
└────────────┴────────────┴───────────────┴────────────────────────────────┘
```

---

## 9. Agent Reuse Map

Shows how existing agents are reused across steps:

```mermaid
flowchart LR
    subgraph AGENTS["Available Agents"]
        A1["researcher"]
        A2["codebase-doc-collector"]
        A3["architecture-doc-collector"]
        A4["architecture-advisor"]
        A5["technical-writer"]
        A6["planner"]
        A7["tdd-guide"]
        A8["code-reviewer"]
        A9["security-reviewer"]
    end

    subgraph STEPS["Pipeline Steps"]
        S1["1. Research"]
        S2["2. Design"]
        S3["3. Plan"]
        S4["4. Implement"]
        S5["5. Review"]
        S6["6. Document"]
    end

    A1 -->|"Lead"| S1
    A2 -->|"code-scanner"| S1
    A3 -->|"arch-scanner"| S1
    A4 -->|"Lead"| S2
    A5 -->|"contract-writer"| S2
    A6 --> S3
    A7 -->|"developer"| S4
    A8 -->|"reviewer"| S4
    A8 -->|"quality"| S5
    A9 -->|"security"| S5
    A5 -->|"Lead +\nfeature-writer"| S6
    A2 -->|"delta-scanner"| S6

    style AGENTS fill:#f5f5f5,stroke:#999
    style STEPS fill:#e3f2fd,stroke:#1565c0
```

---

## Related

- [README](README.md) — Overview, quick start
- [Artifacts spec](artifacts.md) — File format details
- [State management](state-management.md) — state.json, auto-continue
