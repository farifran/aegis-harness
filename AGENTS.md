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
- epistemic containment principles.

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

1. AGENTS.md
2. .harness/
3. .skills/
4. runtime_aegis.sh
5. aider.conf.yml
6. docs/active_task.md
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

## Runtime Constraint

The runtime must remain semantically blind.

It may:
- execute modes;
- read explicit runtime state;
- route deterministic transitions;
- enforce epistemic isolation;
- validate mechanical execution integrity.

It must NOT:
- interpret cognition;
- infer meaning;
- validate correctness;
- analyze findings;
- orchestrate semantically;
- collapse uncertainty into operational decisions.

Runtime orchestration must remain mechanically deterministic.

---

## Mode Constraint

Modes are bounded cognitive contracts.

Modes may:
- observe;
- infer;
- repair;
- optimize;
- falsify;
- validate.

Modes must NOT:
- redefine governance;
- redefine runtime authority;
- create hidden orchestration;
- establish architectural truth;
- silently persist cognition across modes.

Mode behavior belongs in:
.skills/

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

## Epistemic Discipline

Structural truth emerges from:
- observable repository behavior;
- dependency topology;
- mechanically enforceable guarantees;
- explicit structural evidence.

Do not transform:
- semantic suspicion;
- inferred relationships;
- partial evidence;
- exploratory findings;
into:
- structural certainty.

Confidence must remain proportional to observable evidence.

Absence of contradiction is not evidence of correctness.

Semantic plausibility alone does not establish truth.

Unknowns must remain explicitly bounded.

The following remain advisory unless structurally confirmed:
- documentation;
- comments;
- plans;
- semantic interpretation;
- weak signals;
- inferred relationships;
- volatile operational context.

Preserve proportionality between:
- confidence and evidence;
- mutation and approved scope;
- optimization and operational need;
- escalation and structural risk.

---

## Memory Discipline

The system contains two memory classes.

### Volatile Memory

docs/active_task.md

Used for:
- active operational state;
- bounded cross-mode handoff;
- unresolved uncertainty;
- escalation continuity;
- operational epistemic discipline.

It remains:
- transient;
- uncertainty-sensitive;
- non-authoritative.

It does NOT function as:
- persistent cognitive memory;
- claim persistence;
- topology authority;
- architectural truth storage.

### Epistemic Continuity

Cross-mode epistemic continuity belongs exclusively to:

.harness/state/epistemic_state.json

This state remains:
- revisable;
- uncertainty-sensitive;
- structurally falsifiable;
- non-authoritative.

Epistemic continuity must not silently transform:
- inferred claims;
- topology assumptions;
- adversarial findings;
- operational hypotheses;
into structural truth.

Persistent continuity exists to:
- preserve bounded cognition;
- maintain falsification survivability;
- reduce hidden continuity leakage;
- support revisable operational reasoning.

It must not become:
- architectural authority;
- governance replacement;
- semantic truth persistence;
- implicit ontology.

### Persistent Memory

Git history and canonical repository structure.

Persistent state requires:
- explicit mutation;
- observable justification;
- structural accountability.

No mode may silently transform volatile suspicion into historical truth.

---

## Source-of-Truth Boundaries

### .harness/

Contains:
- structural metadata;
- enforcement definitions;
- architectural graph information;
- repository structural truth artifacts;
- epistemic continuity state.

It must NOT contain:
- runtime cognition;
- hidden operational memory;
- mode-local behavioral logic.

### .skills/

Contains:
- mode-specific cognitive contracts;
- bounded reasoning rules;
- operational constraints per mode.

Modes define:
- purpose;
- inputs;
- allowed operations;
- forbidden operations;
- escalation conditions;
- output discipline.

Modes must not redefine constitutional governance.

### runtime_aegis.sh

Defines:
- deterministic orchestration;
- explicit state routing;
- execution sequencing;
- epistemic isolation enforcement;
- mechanical execution integrity enforcement.

The runtime must remain semantically blind.

### aider.conf.yml

Defines:
- executor operational configuration;
- interaction behavior;
- executor automation;
- validation execution behavior.

It must not define:
- governance;
- structural truth;
- runtime authority;
- constitutional cognition;
- continuity governance.

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
- epistemic continuity silently ossifying into truth persistence.

---

## Final Principle

Governance remains explicit.

Runtime remains deterministic.

Cognition remains bounded.

Memory remains controlled.

Epistemic continuity remains revisable.

Structural truth remains evidence-bound.

Confidence remains proportional to observable reality.