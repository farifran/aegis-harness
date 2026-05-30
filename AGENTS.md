# AGENTS.md — Aegis Harness Constitutional Foundation

## Purpose

This repository implements Aegis Harness: a runtime-sovereign, capability-grounded architecture for bounded cognition and controlled mutation.

The purpose of this constitution is to define:

- authority boundaries
- epistemic boundaries
- runtime boundaries
- mutation boundaries
- memory boundaries
- continuity boundaries

Aegis is not a conventional assistant framework.

Aegis is a control system for cognition, evidence, and mutation.

---

## Constitutional Principles

### 1. Runtime Sovereignty

The runtime owns orchestration, lifecycle, capability exposure, cleanup, and continuity promotion.

The model does not own authority.

The model does not own persistence.

The model does not own mutation boundaries.

The model consumes what the runtime exposes.

### 2. Capability Grounding

Repository awareness must be explicit.

The model may only reason over runtime-exposed capabilities, manifests, payloads, and promoted artifacts.

Implicit repository inheritance is not allowed.

### 3. Disposable Cognition

Cognition is disposable.

Mode execution may produce reasoning, but reasoning itself is not persistent state.

Only runtime-promoted artifacts may survive across modes.

### 4. Explicit Continuity

Continuity is runtime-owned and artifact-mediated.

No mode may carry hidden cognition into the next mode.

What survives is what the runtime promotes.

### 5. Bounded Mutation

Mutation must remain bounded to explicit authorized surfaces.

Mutation modes may transform the repository, but only within runtime-defined scope and capability boundaries.

### 6. Epistemic Separation

The system must separate:

- observation
- interpretation
- falsification
- correction
- verification

Not all responsibilities belong to the same mode.

---

## Architectural Model

Aegis is organized around a layered runtime topology:

### Layer 1 — Constitutional Foundation

Layer 1 defines the system's fixed rules, capability topology, and governance boundaries.

Primary Layer 1 artifacts:

- `AGENTS.md`
- `.harness/architecture_graph.json`

Layer 1 should remain stable unless the constitutional model changes.

### Layer 2 — Operational Runtime

Layer 2 implements the runtime mechanics that enforce Layer 1.

Primary Layer 2 artifacts:

- `runtime_aegis.sh`
- `scripts/execute_mode.sh`
- `scripts/substrates/raw_llm.sh`
- `scripts/capabilities/generate_manifest.sh`
- capability handler scripts under `scripts/capabilities/`

### Layer 3 — Future Capability Runtime

Layer 3 is a future evolution of the runtime and must not be assumed or invented prematurely.

Layer 3 should only be introduced after Layer 1 and Layer 2 are fully consolidated.

---

## Mode Topologies

### Discovery

Discovery is bounded observation.

Discovery transforms runtime-exposed evidence into explicit observations.

Discovery does not interpret.
Discovery does not validate.
Discovery does not mutate.
Discovery does not redesign.
Discovery does not infer causality.

Discovery answers only what is directly observable.

### Forensics

Forensics is bounded interpretation.

Forensics consumes explicit observations and transforms them into evidence-backed interpretations.

Forensics does not mutate.
Forensics does not validate final outcomes.
Forensics does not own persistence.

### Repair

Repair is bounded correction.

Repair is allowed to combine observation, interpretation, causal reasoning, and mutation because correction requires context.

Repair may use context-heavy tools and mutation-oriented substrates.

Repair must remain within authorized mutation boundaries.

### Optimize

Optimize is bounded simplification.

Optimize may reduce complexity, improve maintainability, and remove unnecessary structure.

Optimize must preserve correctness and stay within authorized mutation boundaries.

### Adversarial

Adversarial is bounded falsification.

Adversarial exists to challenge the result of Repair and Optimize.

Adversarial does not perform initial discovery.

Adversarial attempts to expose weak assumptions, missed cases, and residual risk.

### Validation

Validation is bounded verdict.

Validation complements Adversarial and provides the final judgment on the resulting state.

Validation does not rediscover the same problems.
Validation does not mutate.
Validation does not replace adversarial challenge.

Validation answers whether the end state is acceptable within the expected constraints.

---

## Evidence and Memory Model

Aegis separates three distinct continuity surfaces.

### 1. Capability Payloads

Capability payloads are runtime-exposed evidence from the current execution surface.

They are not memory.
They are evidence.

### 2. Epistemic Handover

Epistemic handover preserves only unresolved observational attention, such as:

- incomplete observations
- uninspected areas
- insufficient evidence
- observed limitations

Epistemic handover must not contain:

- hypotheses
- conclusions
- causal claims
- recommendations
- redesign proposals
- severity judgments
- hidden reasoning chains

Epistemic handover is guidance for further investigation, not truth.

### 3. Git

Git is persistent memory.

Git preserves accepted structural changes, code evolution, and official documentation.

Git is the repository's long-term memory.

---

## Epistemic Handover Rule

If the system needs to preserve unresolved attention between modes, it must do so explicitly through an epistemic handover artifact, not through hidden cognitive state.

Artifacts transport facts.

Epistemic handovers transport incomplete observations.

Artifacts may be consumed as evidence.

Epistemic handovers may only be consumed as investigation guidance.

Epistemic handovers never constitute evidence, truth, findings, conclusions, validation, or authority.

---

## Memory Discipline

The system must not use hidden model memory as a continuity layer.

Allowed continuity surfaces:

- capability payloads
- epistemic handover artifacts
- promoted artifacts
- git

Disallowed continuity surfaces:

- implicit reasoning carryover
- hidden prompt residue
- unbounded conversational memory
- mode-internal private context treated as system state

---

## Runtime Responsibilities

The runtime owns:

- capability environment materialization
- capability payload materialization
- manifest generation
- mode routing
- task framing
- cleanup
- continuity promotion
- execution isolation

The runtime must decide what survives.

The runtime must not allow the model to silently inherit authority.

---

## Execution Surface Rules

The execution surface is disposable.

Every execution should run in a bounded and transient surface, such as a worktree.

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

Readonly capabilities must remain readonly.

Mutation capabilities must remain bounded.

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
- promoted artifact
- runtime sovereignty
- explicit continuity

The project should phase out or constrain legacy phrasing that suggests implicit assistant-style context inheritance.

In particular, terms like "grounding" should be used carefully and only where they still reflect the operational reality of capability exposure.

---

## Governance and Precedence

Precedence order:

1. constitutional rules in `AGENTS.md`
2. architectural topology in `.harness/architecture_graph.json`
3. runtime policy in `config.sh`
4. capability contracts and manifests
5. mode skills
6. transient runtime artifacts
7. git history

Lower layers must not contradict higher layers.

If a lower layer conflicts with this constitution, the constitution wins.

---

## Proven / Intended / Deferred

### Proven

- runtime sovereignty
- capability grounding
- artifact promotion
- disposable cognition
- bounded mutation
- explicit continuity

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

- No hidden continuity.
- No implicit repository inheritance.
- No model-owned persistence.
- No mutation outside authorized surfaces.
- No interpretation masquerading as observation.
- No validation masquerading as discovery.
- No epistemic handover leaking into truth claims.

---

## Summary

Aegis is a runtime-sovereign, capability-grounded architecture for bounded cognition.

Its central idea is that the runtime owns authority and continuity, while the model consumes only explicit capability surfaces and produces explicit artifacts.

Discovery observes.
Forensics interprets.
Repair mutates.
Optimize simplifies.
Adversarial challenges.
Validation judges.

The runtime preserves only what must survive.

Everything else is disposable.
