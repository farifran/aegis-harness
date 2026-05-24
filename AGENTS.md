# AEGIS HARNESS — AGENTS.md

## Purpose

This file defines the constitutional governance of the Aegis Harness.

It is the highest operational authority in the repository.

It defines:
- governance boundaries;
- authority ownership;
- source-of-truth hierarchy;
- memory discipline;
- orchestration limits;
- execution isolation principles.

It does NOT define:
- mode-local cognition;
- runtime sequencing details;
- implementation behavior;
- provider routing;
- workflow heuristics;
- tool-specific execution.

Those belong to their respective layers.

---

## Authority Hierarchy

The authoritative order of the system is:

1. `AGENTS.md`
2. `.harness/`
3. `.skills/`
4. `runtime_aegis.sh`
5. `aider.conf.yml`
6. `docs/active_task.template.md`
7. repository implementation

Higher layers constrain lower layers.

Lower layers must not redefine higher layers.

---

## Core Separation Principle

The Aegis Harness separates:

| Layer | Responsibility |
|---|---|
| Governance | constitutional authority |
| Runtime | deterministic orchestration |
| Modes | bounded cognition |
| Enforcement | mechanically enforceable constraints |
| Session State | controlled operational continuity |
| Implementation | bounded repository mutation |

No layer may silently absorb another layer’s authority.

---

## Runtime Sovereignty

The runtime is the sovereign operational authority.

The runtime governs:
- execution lifecycle;
- sandbox isolation;
- context injection;
- artifact validation;
- mutation validation;
- continuity persistence;
- recovery state.

The runtime is intentionally:
- semantically blind;
- mechanically deterministic.

The runtime must not:
- interpret cognition quality;
- semantically repair artifacts;
- infer hidden intent;
- establish architectural truth;
- autonomously redesign orchestration.

Runtime authority is mechanical only.

---

## Continuity Model

Persistent doctrine exists in:

- `docs/active_task.template.md`

Live session continuity exists in:

- `.harness/runtime/active_task.md`

Recovery state exists in:

- `.harness/runtime/last_good_active_task.md`

Continuity ownership belongs exclusively to the runtime.

Modes never directly persist continuity.

The runtime:
- validates artifacts;
- appends deterministic execution blocks;
- persists continuity;
- governs recovery state.

Continuity must never emerge implicitly through:
- executor persistence;
- hidden runtime state;
- cached conversational memory;
- repository-derived latent cognition;
- implicit orchestration carryover.

---

## Execution Isolation

Execution environments are ephemeral and disposable.

Each mode executes inside an isolated disposable sandbox or git worktree.

Execution sessions must not retain:
- hidden conversational memory;
- latent runtime continuity;
- repository-derived cognitive persistence;
- implicit operational carryover.

Each execution session must:
- receive explicitly governed context only;
- expose only authorized continuity surfaces;
- terminate without preserving latent cognition.

Execution isolation exists to preserve:
- bounded cognition;
- revisability;
- explicit continuity governance;
- operational containment.

Executors remain disposable cognition engines.

---

## Mode Capability Model

The system distinguishes between:
- hard containment modes;
- mutation-authorized modes.

### Hard Containment Modes
Modes:
- discovery
- forensics
- validation
- adversarial

These modes are:
- read-only;
- filesystem bounded;
- operationally contained.

They must not:
- mutate implementation surfaces;
- persist continuity;
- govern runtime state.

### Mutation-Authorized Modes
Modes:
- repair
- optimize

These modes may mutate only:
- explicitly authorized filesystem surfaces;
- runtime-approved implementation boundaries.

Mutation authority is:
- capability-scoped;
- runtime-validated;
- mechanically observable.

Mutation authority never implies persistence authority.

---

## Mutation Governance

Filesystem mutation must remain mechanically observable.

The runtime validates mutation boundaries through:
- explicit editable surfaces;
- git diff inspection;
- capability-bound mutation validation;
- execution containment boundaries.

Unauthorized mutation must fail explicitly.

Mutation containment exists to preserve:
- bounded authority;
- deterministic execution;
- architectural integrity;
- operational observability.

---

## Structured Output Governance

Modes must emit mechanically parseable artifacts.

Artifacts must remain:
- explicit;
- bounded;
- revisable;
- operationally observable.

Artifacts communicate through:
- sentinel framing;
- strict JSON structure;
- runtime validation.

Freeform hidden reasoning persistence is forbidden.

Artifacts exist to preserve:
- inspectability;
- containment;
- deterministic lifecycle governance.

---

## Context Governance

Cognition must receive only proportionally necessary context.

Unbounded repository exposure is forbidden.

Context visibility must remain:
- explicit;
- bounded;
- operationally justified;
- proportional to execution scope.

Reducing cognitive surface area is a containment mechanism and a runtime governance responsibility.

---

## Repository Governance

Repository structure is authoritative over semantic plausibility.

Architectural truth must emerge from:
- observable structure;
- mechanically verifiable constraints;
- dependency relationships;
- execution reality.

Semantic plausibility alone never establishes correctness.

Absence of contradiction does not establish truth.

---

## Human Authority

Humans retain authority over:
- architectural redesign;
- escalation resolution;
- structural acceptance;
- operational risk tolerance;
- final validation judgment.

The system may:
- assist;
- pressure-test;
- falsify;
- propose;
- surface contradictions.

It may not self-authorize structural reinvention.

Fact must remain prioritized over:
- flattery;
- agreement pressure;
- semantic confidence;
- premature certainty.

---

## Failure Philosophy

Failure visibility is preferred over hidden semantic repair.

The system must fail explicitly when:
- uncertainty cannot be bounded;
- artifacts become invalid;
- execution integrity is compromised;
- mutation boundaries are violated;
- cognition exceeds operational constraints.

Silent correction is forbidden.

Operational transparency is preferred over artificial smoothness.

---

## Prohibited System Behaviors

The Aegis Harness must not allow:
- runtime semantic cognition;
- hidden orchestration loops;
- implicit cross-mode memory;
- speculative redesign drift;
- enforcement overreach into governance;
- tooling authority inversion;
- semantic suspicion presented as truth;
- uncertainty collapse into unsupported certainty;
- topology assumptions becoming architectural authority;
- executor state becoming implicit memory;
- unauthorized filesystem mutation;
- continuity ownership outside runtime governance.

---

## Final Principle

Governance remains explicit.

Runtime remains deterministic.

Cognition remains bounded.

Mutation remains capability-scoped.

Memory remains controlled.

Continuity remains runtime-owned.

Structural truth remains evidence-bound.

Confidence remains proportional to observable reality.

Modes produce cognition.
Runtime owns continuity.