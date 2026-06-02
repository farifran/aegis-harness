# Aegis Harness Summary

## Purpose of This Document

This file is a compact operational summary for developers and other AI systems.

It explains:

- what Aegis Harness is;
- why the system is designed the way it is;
- which files are authoritative;
- how execution actually works today;
- what the current repository state appears to be;
- which risks or open questions still exist.

This document is descriptive, not constitutional.

If there is any conflict between this file and the canonical system contract, the precedence order is:

1. `AGENTS.md`
2. `.harness/config.sh`
3. runtime-managed manifests and capability contracts
4. mode contracts under `.skills/`
5. transient runtime artifacts under `.harness/runtime/`
6. everything else

## One-Sentence System Summary

Aegis Harness is a runtime-sovereign, capability-exposed execution system that keeps cognition bounded, evidence explicit, mutation constrained, and persistence out of the model.

## What the System Is Trying to Prevent

The system exists to prevent a familiar failure mode in AI tooling: the model silently becoming the owner of context, authority, persistence, and orchestration.

The design is intentionally shaped to block:

- assistant-style implicit repository awareness;
- hidden memory across runs or modes;
- mutation outside explicit runtime boundaries;
- interpretation being mistaken for evidence;
- transient prompts becoming unofficial persistence layers;
- ad hoc tool use standing in for capability contracts.

In short, the runtime governs the system; the model consumes bounded evidence.

## Core Justifications

### 1. Runtime sovereignty

Why it exists:

- orchestration must remain mechanical and externally auditable;
- cleanup and persistence decisions should not depend on model behavior;
- mode routing and capability exposure are authority decisions, not reasoning decisions.

How it appears in the repo today:

- `runtime_aegis.sh` owns orchestration, cleanup, execution surface lifecycle, artifact promotion, and epistemic handover lifecycle;
- `.harness/config.sh` defines the capability registry, execution engines, evidence policies, and runtime defaults.

### 2. Capability exposure instead of implicit repository access

Why it exists:

- a model should only know what the runtime explicitly exposed;
- this makes evidence inspectable and authority reviewable.

How it appears today:

- capabilities are declared in `.harness/config.sh`;
- handlers live under `scripts/capabilities/`;
- payloads are materialized into `.harness/runtime/capability_payloads/`;
- the readonly substrate consumes those payloads rather than scanning the repository freely.

### 3. Disposable cognition

Why it exists:

- model reasoning is not trusted as persistent state;
- continuity must be explicit, bounded, and runtime-owned.

How it appears today:

- no mode writes its own memory;
- the only transient continuity surface is the runtime-owned epistemic handover;
- accepted structural memory lives in git, not in model state.

### 4. Three operational memory surfaces only

Why it exists:

- the system needs a strict separation between evidence, guidance, and persistence;
- otherwise accidental intermediate memory layers reappear.

Current canonical surfaces:

1. capability payloads: runtime-owned evidence;
2. epistemic handover: incomplete routed attention only;
3. git: persistent memory.

### 5. Bounded mutation

Why it exists:

- readonly analysis and mutation are different authority regimes;
- mixing them too early causes hidden escalation.

How it appears today:

- readonly modes use the raw substrate;
- mutation modes are configured to use `aider`;
- execution surfaces are only created when the active mode requires mutation-oriented infrastructure.

### 6. Epistemic separation

Why it exists:

- observation, interpretation, falsification, correction, and judgment are different tasks;
- collapsing them creates overconfident outputs and unclear contracts.

How it appears today:

- `discovery` is bounded observation;
- `forensics` is bounded interpretation;
- `adversarial` is bounded falsification;
- `validation` is bounded verdict;
- `repair` and `optimize` are bounded mutation modes.

## Canonical Files and Why They Matter

### `AGENTS.md`

This is the constitutional foundation.

It defines:

- runtime sovereignty;
- capability exposure rules;
- disposable cognition;
- the three-surface operational memory model;
- the meaning of each mode;
- the semantics of epistemic handover;
- the role of `investigation_input`.

If someone wants to understand what the system is allowed to mean, start here.

### `.harness/config.sh`

This is the runtime policy and registry layer.

It defines:

- system metadata;
- runtime directories;
- the canonical paths for target profile and handover;
- default `AEGIS_INVESTIGATION_INPUT` behavior;
- provider defaults and budgets;
- execution engines by mode;
- capability handlers;
- capability classifications;
- mode-to-capability envelopes;
- evidence profiles.

If someone wants to understand what the runtime will expose or allow, this is the main file.

### `runtime_aegis.sh`

This is the sovereign runtime orchestrator.

It currently owns:

- runtime validation;
- investigation input resolution;
- epistemic handover preparation and promotion;
- new-investigation handover reset for discovery;
- execution surface preparation when needed;
- cleanup of runtime-owned transient surfaces;
- delegation to the executor.

### `scripts/execute_mode.sh`

This is the protocol VM.

It consumes runtime-owned state and performs:

- execution engine resolution;
- capability envelope resolution;
- evidence profile selection;
- capability invocation;
- payload persistence;
- substrate invocation;
- candidate artifact validation.

It is intentionally not the runtime.

### `scripts/substrates/raw_llm.sh`

This is the readonly cognition substrate.

It:

- accepts only readonly manifests;
- requires explicit payload selection;
- requires `AEGIS_INVESTIGATION_INPUT` to exist;
- builds the bounded prompt context;
- treats the model as a JSON artifact generator.

### `scripts/lib/epistemic_handover.sh`

This file is the current canonical handover schema helper.

Its existence matters because the handover schema is now shared instead of duplicated between the runtime and the runtime-bound capability reader.

That reduces schema drift.

### `scripts/capabilities/runtime/read_epistemic_handover.sh`

This is the runtime-bound capability that exposes the handover as evidence.

It must:

- fail if runtime context is absent;
- avoid hardcoded fallback paths;
- avoid autodiscovery;
- validate the handover schema before exposing it.

### `.skills/`

These files define mode-specific cognition contracts.

In the current system state, `discovery` and `forensics` explicitly include `handover_attention` expectations in their output contracts.

## How Execution Works Today

The practical flow is:

1. The runtime loads `.harness/config.sh` and validates required runtime state.
2. The runtime prepares the runtime-owned epistemic handover files.
3. The runtime resolves one active `AEGIS_INVESTIGATION_INPUT`.
4. If the mode is `discovery`, the runtime resets handover continuity to start a new investigation boundary.
5. The runtime removes stale transient residue.
6. The runtime prepares a disposable execution surface only for mutation modes.
7. The runtime prepares capability environment and payload directories.
8. The runtime generates the runtime-owned capability manifest.
9. The executor resolves the active capability envelope and evidence profile.
10. Capability handlers materialize payloads.
11. The substrate consumes selected payloads and emits one JSON artifact.
12. The runtime validates and promotes that artifact.
13. The runtime writes the new epistemic handover and updates the last-good copy.
14. The runtime cleans up transient state according to policy.

## Current Continuity Model

### Epistemic handover

The handover is now a runtime-owned JSON object with exactly two top-level fields:

- `artifact_snapshot`
- `epistemic_state`

`epistemic_state` is intentionally minimal and currently uses exactly:

- `next_attention_targets`
- `attention_scope`
- `attention_reason`

This is a major recent simplification.

The handover is no longer supposed to accumulate legacy lists such as pending items or broad unresolved buckets.

Its job is narrower:

- preserve the minimum routed attention for the next mode;
- not preserve historical reasoning;
- not act as evidence;
- not act as a fourth memory surface.

### Investigation input

The system currently treats `investigation_input` as the single active demand surface for an investigation.

Important current properties:

- the runtime consumes it regardless of whether it originated as an issue or a prompt;
- `discovery` starts a new investigation boundary;
- later modes inherit or validate against the current investigation boundary;
- the runtime persists the active `investigation_input` inside `artifact_snapshot` as transient metadata;
- if none is provided, the runtime now applies the explicit default:

`Enumerate runtime-exposed evidence and observable system structure.`

When that default is used, the runtime logs:

- `[AEGIS][RUNTIME]`
- `No investigation input provided.`
- `Using default exploratory investigation.`

This matters because the system now avoids hidden fallback behavior.

## Current Mode Topology

### Readonly modes

- `discovery`
- `forensics`
- `validation`
- `adversarial`

These use the raw readonly substrate.

### Mutation modes

- `repair`
- `optimize`

These are configured to use `aider` as the execution engine.

## Current Capability Topology

Readonly capabilities configured in the repo today include:

- `filesystem.list_tree`
- `filesystem.read`
- `filesystem.search_symbol`
- `git.status`
- `git.diff`
- `runtime.read_target_system_profile`
- `runtime.read_epistemic_handover`

Important nuance:

- `git.diff` is registered as readonly, but only exposed through the bounded mutation envelope;
- runtime-bound capabilities require runtime-materialized context and are not allowed to discover that context on their own.

## Current Repository State

This section reflects the observed repository and workspace state at the time this summary was generated.

### Architecture state

- the constitutional model is present and explicit in `AGENTS.md`;
- the operational registry is centralized in `.harness/config.sh`;
- the runtime is still the largest and most complex orchestration file;
- the handover schema helper has been extracted into `scripts/lib/epistemic_handover.sh`, which reduces duplication;
- readonly cognition is routed through `scripts/substrates/raw_llm.sh`;
- mutation modes are declared but not described in detail in this file beyond their configured engine;
- `target_system_profile.yml` is currently present but empty in practice, with empty `characteristics`, `constraints`, and `preferences` maps.

### State of continuity changes

The recent continuity migration appears to have landed with these properties:

- handover uses routed attention rather than accumulated unresolved lists;
- `investigation_input` is now a first-class runtime concern;
- discovery resets investigation continuity;
- forensics is expected to stay within the same investigation boundary;
- the handover schema is shared through a helper rather than duplicated inline.

### Observed session state

Observed in the current workspace session:

- last observed `bash runtime_aegis.sh forensics` exited with code `0`;
- last observed `bash scripts/test_runtime_contract.sh` exited with code `1`.

This document does not claim a root cause for that failing harness.

It only records that the failure was observed in the current session state.

## What Looks Stable

Based on the repository structure and current contracts, these parts look intentional and central:

- the constitutional model in `AGENTS.md`;
- the three-surface operational memory discipline;
- the runtime-bound capability contract;
- the distinction between readonly cognition and bounded mutation;
- the minimal handover schema;
- the single-demand `investigation_input` model.

## What Still Looks Sensitive

These areas are likely to need careful handling in future changes:

- `runtime_aegis.sh`, because orchestration pressure tends to accumulate there;
- handover lifecycle logic, because it sits at the boundary between continuity and hidden memory;
- investigation input propagation, because it now spans runtime, executor, substrate, and tests;
- harness reliability, because at least one official test was observed failing in the current session;
- `README.md`, because it contains useful material but also mixes canonical architecture with setup snippets and less authoritative operational notes.

## Recommended Reading Order for New Humans or AIs

If someone needs to understand the system quickly and correctly, read in this order:

1. `AGENTS.md`
2. `.harness/config.sh`
3. `runtime_aegis.sh`
4. `scripts/execute_mode.sh`
5. `scripts/substrates/raw_llm.sh`
6. `scripts/lib/epistemic_handover.sh`
7. `scripts/capabilities/runtime/read_epistemic_handover.sh`
8. `.skills/discovery.md`
9. `.skills/forensics.md`
10. `scripts/test_runtime_contract.sh`
11. `scripts/test_readonly_modes.sh`
12. `scripts/test_constitutional_invariants.sh`

## Practical Guidance for Future Changes

If you modify this system, preserve these boundaries:

- do not let the model own persistence;
- do not add a fourth operational memory surface;
- do not let runtime-bound capabilities autodiscover context;
- do not let epistemic handover become a findings log;
- do not collapse readonly cognition into mutation authority;
- do not treat `investigation_input` as evidence;
- do not make the executor responsible for runtime lifecycle decisions.

If you simplify the codebase, the best places to keep simplifying are:

- orchestration density inside `runtime_aegis.sh`;
- duplicated validation patterns across scripts;
- documentation overlap between `README.md` and the canonical contract files.

## Final Summary

Aegis Harness is not trying to be a chat assistant with tools.

It is trying to be a bounded execution control system where:

- the runtime owns authority;
- capabilities define what can be seen;
- artifacts are mechanically validated;
- continuity is explicit and minimal;
- mutation is bounded;
- git is the only persistent memory.

At the current repository state, that design is visible and mostly coherent.

The main active pressure point is still orchestration complexity in the runtime, especially around handover lifecycle and investigation input propagation.