# AGENTS.md — Aegis Harness Constitutional Foundation

## Purpose

This repository implements Aegis Harness: a runtime-sovereign, capability-exposed architecture for bounded cognition and controlled mutation.

The constitution defines the system’s authority boundaries, epistemic boundaries, runtime boundaries, mutation boundaries, memory boundaries, and continuity boundaries.

Aegis is not a conventional assistant framework.

Aegis is a control system for cognition, evidence, and mutation.

---

## Core Constitutional Principles

### Runtime Sovereignty

The runtime owns orchestration, lifecycle, capability exposure, cleanup, artifact promotion, epistemic handover lifecycle, target-system profile materialization, and persistence decisions.

The model does not own authority.

The model does not own persistence.

The model does not own mutation boundaries.

The model consumes what the runtime exposes.

### Capability Exposure

Repository awareness must be explicit.

The model may only reason over runtime-exposed capabilities, runtime-exposed evidence, manifests, capability payloads, epistemic handovers, and target-system profiles when explicitly exposed by the runtime.

Implicit repository inheritance is not allowed.

### Disposable Cognition

Cognition is disposable.

Mode execution may produce reasoning, but reasoning itself is not evidence, not epistemic handover, and not memory.

No hidden cognition survives across modes.

### Operational Memory Discipline

Aegis uses exactly three operational surfaces for evidence and continuity:

- Capability payloads are runtime-owned evidence, not memory.
- Epistemic handover is incomplete epistemic attention, not truth, not evidence, not interpretation, and not memory.
- Git is persistent memory.

No other intermediate continuity or operational memory surface exists.

### Bounded Mutation

Mutation must remain bounded to explicit authorized surfaces.

Mutation modes may transform the repository, but only within runtime-defined scope and capability boundaries.

### Epistemic Separation

The system must separate:

- observation
- interpretation
- falsification
- correction
- verification

Not all responsibilities belong to the same mode.

---

## Architectural Model

Aegis is organized around a layered runtime topology.

### Layer 1 — Constitutional Foundation

Layer 1 defines the system’s fixed rules, constitutional semantics, and governance boundaries.

Primary Layer 1 artifacts:

- `AGENTS.md`

Layer 1 should remain stable unless the constitutional model changes.

### Layer 2 — Operational Runtime

Layer 2 implements the runtime mechanics that enforce Layer 1.

Primary Layer 2 artifacts:

- `.harness/config.sh`
- `runtime_aegis.sh`
- `scripts/execute_mode.sh`
- `scripts/substrates/raw_llm.sh`
- `scripts/capabilities/generate_manifest.sh`
- capability handler scripts under `scripts/capabilities/`

### Layer 3 — Future Capability Runtime

Layer 3 is a future evolution of the runtime and must not be assumed or invented prematurely.

Layer 3 should only be introduced after Layer 1 and Layer 2 are fully consolidated.

---

## Mode Semantics

### Discovery

Discovery is bounded observation.

Discovery transforms runtime-exposed evidence into explicit observations.

Discovery establishes a new investigation boundary.

Epistemic continuity is scoped to the lifecycle of a single investigation.

Transient continuity state from previous investigations must not influence subsequent investigations.

Discovery does not interpret.
Discovery does not validate.
Discovery does not mutate.
Discovery does not redesign.
Discovery does not infer causality.

Discovery may seed the next investigation attention only by identifying the minimum `next_attention_targets`, `attention_scope`, and `attention_reason` needed for the next mode.

Discovery answers only what is directly observable.

### Forensics

Forensics is bounded interpretation.

Forensics consumes explicit observations and transforms them into evidence-backed interpretations.

Forensics may narrow the current investigation attention by reducing noise and preserving only the minimum `next_attention_targets`, `attention_scope`, and `attention_reason` still needed.

Forensics does not mutate.
Forensics does not validate final outcomes.
Forensics does not own persistence.

### Repair

Repair is bounded correction.

Repair is allowed to combine observation, interpretation, causal reasoning, and mutation because correction requires context.

Repair may use context-heavy tools and mutation-oriented substrates.

Repair may translate routed attention into the smallest action target still required for bounded correction.

Repair must remain within authorized mutation boundaries.

### Optimize

Optimize is bounded simplification.

Optimize may reduce complexity, improve maintainability, and remove unnecessary structure.

Optimize may translate routed attention into the smallest simplification target still required.

Optimize must preserve correctness and stay within authorized mutation boundaries.

### Adversarial

Adversarial is bounded falsification.

Adversarial exists to challenge the result of Repair and Optimize.

Adversarial may translate routed attention into the smallest falsification target still worth challenging.

Adversarial does not perform initial discovery.

Adversarial attempts to expose weak assumptions, missed cases, and residual risk.

### Validation

Validation is bounded verdict.

Validation complements Adversarial and provides the final judgment on the resulting state.

Validation may converge routed attention toward closure and should leave no residual attention unless additional judgment is still required.

Validation does not rediscover the same problems.
Validation does not mutate.
Validation does not replace adversarial challenge.

Validation answers whether the end state is acceptable within the expected constraints.

---

## Foundational Definitions

- Discovery is an observation topology.
- Forensics is an interpretation topology.
- Repair is a correction topology.
- Optimize is a simplification topology.
- Adversarial is a falsification topology.
- Validation is a verdict topology.
- An artifact is a promoted fact.
- An epistemic handover is a runtime-owned transient artifact containing `artifact_snapshot` and `epistemic_state`.
- A capability payload is runtime-owned evidence.
- Git is persistence.
- `target_system_profile.yml` is a runtime-exposed target-system specification.

### Investigation Input

Prompts and issues are operator inputs that define an investigation.

The runtime consumes one `investigation_input`.

The runtime does not distinguish between informal and formal human wording.

`investigation_input` may be carried as transient runtime-owned metadata inside `artifact_snapshot`, but it does not create a fourth operational memory surface.

The runtime must not materialize an intermediate demand file as a separate continuity surface.

---

## Evidence and Memory Model

Aegis uses exactly three operational surfaces for evidence and continuity.

### 1. Capability Payloads

Capability payloads are runtime-exposed evidence from the current execution surface.

They are not memory.
They are evidence.

### 2. Epistemic Handover

Epistemic handover is a single runtime-owned transient artifact with exactly two sections:

- `artifact_snapshot`
- `epistemic_state`

`artifact_snapshot` stores only the last transient artifact snapshot promoted by the runtime.

`artifact_snapshot`:

- is runtime-written
- is single-snapshot only
- is not a history log
- is not evidence
- is not truth
- is not persistent memory

`epistemic_state` preserves only the minimum routed attention required for the next stage of the current investigation.

`epistemic_state` must use exactly these fields:

- `next_attention_targets`
- `attention_scope`
- `attention_reason`

`epistemic_state`:

- is runtime-written
- is replacement state, not accumulation
- is not historical context
- is not evidence
- is not truth
- is not backlog
- is not interpretation

`epistemic_state` must not contain:

- hypotheses
- conclusions
- causal claims
- recommendations
- redesign proposals
- severity judgments
- historical logs
- backlog items
- hidden reasoning chains

Epistemic handover remains an incomplete epistemic attention surface.

`artifact_snapshot` is a transient promoted runtime snapshot.

`epistemic_state` is promoted incomplete observation.

The runtime is the sole writer of the epistemic handover file.

Modes may suggest routed attention in their artifacts, but they do not write the handover directly.

The runtime alone decides the final `epistemic_state`, replaces the prior state, and drops routed attention that is no longer needed.

It is not truth.
It is not evidence.
It is not interpretation.
It is not memory.

Epistemic handover is investigation-scoped continuity only.

It must not transport transient continuity from one investigation into the next.

Cross-investigation continuity may derive only from persistent repository state and other explicit runtime-exposed artifacts, such as target-system profiles and produced files.

### 3. Git

Git is persistent memory.

Git preserves accepted structural changes, code evolution, and official documentation.

Git is the repository’s long-term memory.

---

## Epistemic Handover Rule

If the system needs to preserve unresolved attention between modes, it must do so explicitly through an epistemic handover artifact, not through hidden cognitive state.

That continuity is valid only within the current investigation lifecycle.

Discovery begins a new investigation lifecycle.

That lifecycle is defined by one runtime-consumed `investigation_input`.

Capability payloads transport runtime-owned evidence.

Epistemic handovers transport one transient `artifact_snapshot` plus one `epistemic_state`.

Git transports accepted persistent state.

Only `epistemic_state` may be consumed as investigation guidance.

`artifact_snapshot` may be inspected as transient runtime context only.

`epistemic_state` must be replaced, reduced, or cleared on each runtime write.

Epistemic handovers never constitute evidence, truth, findings, conclusions, validation, or authority.

---

## Target System Profile

`target_system_profile.yml` defines explicit characteristics, constraints, and preferences of the target system.

It is a data artifact, not a constitutional surface.

Its semantics are defined by this constitution and must not be duplicated inside the profile itself.

The profile may only inform target-system decisions when exposed through an explicit runtime capability payload.

If the file is absent, or if its declared sections are absent or empty, no additional target-system characteristics are assumed.

Only explicitly declared characteristics, constraints, and preferences may inform target-system decisions.

Absence of a characteristic, constraint, or preference must not be interpreted as the opposite characteristic, constraint, or preference.

`target_system_profile.yml` must not embed governance, runtime philosophy, constitutional semantics, or artifact self-description.

---

## Runtime Responsibilities

The runtime owns:

- capability environment materialization
- capability payload materialization
- manifest generation
- artifact promotion
- mode routing
- task framing
- cleanup
- epistemic handover lifecycle
- target-system profile materialization
- execution isolation

The runtime must not introduce any fourth memory surface.

The runtime must not allow the model to silently inherit authority.

---

## Execution Surface Rules

The execution surface is disposable.

Every execution should run in a bounded and transient execution surface.

The runtime may create, isolate, and destroy execution surfaces as needed.

The execution surface must not become hidden persistent state.

---

## Capability Registry Rules

Every capability must be:

- explicitly named
- explicitly classified
- explicitly contracted
- explicitly handler-mapped

Capabilities must not be ambiguous.

Capabilities must not imply broader authority than declared.

Readonly capability surfaces must remain readonly.

Mutation capabilities must remain bounded.

### Runtime-Bound Capability Contract

Some capabilities are runtime-bound.

Runtime-bound capabilities consume runtime-materialized context rather than discovering inputs on their own.

Current runtime-bound capabilities are:

- `runtime.read_target_system_profile`, which requires `AEGIS_TARGET_SYSTEM_PROFILE_FILE`
- `runtime.read_epistemic_handover`, which requires `AEGIS_EPISTEMIC_HANDOVER_FILE`

If required runtime context is absent, a runtime-bound capability must fail explicitly with `runtime_context_not_initialized`.

Runtime-bound capabilities must not:

- hardcode fallback paths
- autodiscover repository paths
- duplicate runtime policy

---

## Vocabulary Consolidation

The project should prefer the following vocabulary:

- capability payload
- capability environment
- runtime-owned
- readonly cognition
- bounded mutation
- execution surface
- epistemic handover
- target-system profile
- persistent git memory
- runtime sovereignty
- operational memory discipline

The project should phase out or constrain legacy phrasing that suggests implicit assistant-style context inheritance.

Preferred terminology should center capability exposure, runtime-exposed evidence, and capability payloads.

---

## Governance and Precedence

Precedence order:

1. constitutional rules in `AGENTS.md`
2. runtime policy in `.harness/config.sh`
3. capability contracts and manifests
4. mode skills
5. transient runtime artifacts
6. git history

Lower layers must not contradict higher layers.

If a lower layer conflicts with this constitution, the constitution wins.

---

## Proven / Intended / Deferred

### Proven

- runtime sovereignty
- capability exposure
- runtime-exposed evidence
- capability payload evidence
- disposable cognition
- bounded mutation
- epistemic handover guidance-only semantics
- target-system profile exposure

### Intended

- stricter epistemic handover semantics
- stronger capability coercion
- more explicit separation of observation and interpretation

### Deferred

- distributed runtime execution
- advanced sandboxing layers
- cross-provider protocol normalization

---

## Non-Negotiable Constraints

- No hidden operational memory surface.
- No implicit repository inheritance.
- No model-owned persistence.
- No intermediate operational memory surface beyond capability payloads, epistemic handover, and git.
- No mutation outside authorized surfaces.
- No interpretation masquerading as observation.
- No validation masquerading as discovery.
- No epistemic handover leaking into truth claims.
- No target-system profile semantics inside the profile file itself.

---

## Summary

Aegis is a runtime-sovereign, capability-exposed architecture for bounded cognition.

Its central idea is that the runtime owns authority, artifact promotion, and operational memory boundaries, while the model consumes only capability payload evidence and epistemic handover guidance.

Git is the only persistent memory.

Discovery observes.
Forensics interprets.
Repair corrects.
Optimize simplifies.
Adversarial challenges.
Validation judges.

The runtime does not invent intermediate memory.

Everything else is disposable.