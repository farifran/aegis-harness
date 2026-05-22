# AEGIS HARNESS — AGENTS.md

## Purpose

This file defines the constitutional governance of the Aegis Harness.

It is the highest operational authority in the repository.

It defines:
- governance boundaries;
- authority ownership;
- structural invariants;
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
6. `docs/active_task.md`
7. repository implementation

Higher layers constrain lower layers.

Lower layers must not redefine higher layers.

---

## Core Separation Principle

The Aegis Harness preserves explicit separation between:

| Layer | Responsibility |
|---|---|
| Governance | constitutional authority |
| Runtime | deterministic execution routing |
| Modes | bounded cognition |
| Enforcement | mechanically enforceable constraints |
| Memory | controlled persistence |
| Implementation | repository mutation |

No layer may silently absorb another layer’s authority.

---

## Execution Isolation

Execution environments are ephemeral and disposable.

Each execution session should begin from an isolated sandbox or worktree when available.

Executors must not retain:
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

Runtime governance owns:
- continuity authorization;
- persistence authorization;
- artifact lifecycle control.

Executors remain disposable cognition engines.

---

## Continuity Governance

Authorized continuity surfaces are intentionally minimal.

The primary authorized continuity surface is:

- `docs/active_task.md`

No other continuity mechanism should be assumed implicitly.

Continuity must never emerge accidentally through:
- executor persistence;
- hidden runtime state;
- cached conversational memory;
- repository-derived latent cognition;
- implicit orchestration carryover.

All meaningful continuity must remain:
- explicit;
- observable;
- revisable;
- operationally bounded.

---

## Runtime Governance

Runtime layers govern:
- execution lifecycle;
- context injection;
- artifact capture;
- persistence authorization;
- isolation boundaries.

Runtime layers must remain semantically blind.

Runtime must NOT:
- interpret cognition;
- validate reasoning quality;
- rewrite cognition artifacts;
- semantically repair outputs;
- infer missing meaning.

Runtime authority is mechanical only.

---

## Mode Governance

Modes are bounded cognition layers.

Modes may:
- inspect;
- reason;
- explore;
- analyze;
- emit structured artifacts.

Modes must NOT:
- silently redesign systems;
- fabricate hidden architecture;
- invent operational truth;
- mutate repository state unless explicitly authorized;
- accumulate hidden continuity.

Modes remain:
- revisable;
- uncertainty-sensitive;
- operationally bounded.

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

## Structured Output Governance

Modes must emit mechanically parseable artifacts.

Outputs should remain:
- explicit;
- bounded;
- revisable;
- operationally observable.

Freeform hidden reasoning persistence is forbidden.

Runtime artifacts exist to preserve:
- inspectability;
- containment;
- deterministic lifecycle governance.

---

## Orchestration Governance

Cognition and orchestration must remain separated.

Modes may emit:
- findings;
- uncertainty;
- escalation signals;
- bounded observations.

Modes do NOT own:
- execution routing;
- persistence authority;
- orchestration authority;
- lifecycle authority.

Orchestration layers govern:
- transitions;
- escalation handling;
- retries;
- lifecycle progression.

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

## Enforcement Constraint

Only mechanically enforceable constraints belong in enforcement systems.

Enforcement may include:
- AST rules;
- linting;
- type systems;
- CI validation;
- structural verification.

Semantic preference is not structural enforcement.

---

## Failure Philosophy

Failure visibility is preferred over hidden semantic repair.

The system must fail explicitly when:
- uncertainty cannot be bounded;
- artifacts become invalid;
- execution integrity is compromised;
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
- executor state becoming implicit memory.

---

## Final Principle

Governance remains explicit.

Runtime remains deterministic.

Cognition remains bounded.

Memory remains controlled.

Continuity remains explicitly governed.

Structural truth remains evidence-bound.

Confidence remains proportional to observable reality.