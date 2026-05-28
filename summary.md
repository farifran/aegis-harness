# AEGIS HARNESS — CURRENT SYSTEM SUMMARY

## 1. Purpose

Aegis Harness is now operating as a bounded, deterministic, capability-grounded runtime for AI-assisted cognition and bounded mutation.

The system is no longer best understood as a collection of prompts or mode instructions. It now behaves as a runtime-owned execution topology in which:

- the runtime governs lifecycle, orchestration, cleanup, continuity, and persistence decisions;
- modes produce bounded cognition;
- the executor enforces protocol and materializes capability evidence;
- capability surfaces define authority;
- grounding is explicit and runtime-owned;
- execution is disposable and sandboxed;
- repository awareness is capability-bound rather than implicit.

This is the most important architectural shift in the system so far.

---

## 2. Core Architectural Principle

The current principle is:

> Runtime governs execution.  
> Modes reason.  
> Executor enforces protocol.  
> Capabilities bound authority.  
> Grounding is explicit.  
> Persistence is explicit.  
> Continuity is ephemeral.

This principle is now implemented in operational form, not just described in prose.

The consequence is important: the system does not rely on prompt obedience alone. It relies on mechanically enforced execution topology:

- a runtime-owned worktree lifecycle;
- explicit capability environments;
- runtime-materialized capability payloads;
- protocol-framed artifacts;
- provider interaction hardening;
- bounded substrate routing.

---

## 3. What the System Has Become

The current Aegis Harness is best described as:

- a runtime-first execution system;
- a capability-governed cognition system;
- a disposable-sandbox orchestration system;
- a protocol-enforced payload system;
- a repository-inspection system based on explicit capability exposure;
- a bounded-mutation system with authority separation.

It is no longer architecturally accurate to describe it as an assistant workflow, a prompt layer, or a conventional agent framework.

---

## 4. What Was Proved Operationally

Several important things were not merely designed; they were demonstrated through actual runtime execution.

### 4.1 Capability environments exist as real execution surfaces

The runtime now creates `.harness/runtime/capability_env/` and populates it with executable surfaces such as:

- `filesystem.list_tree`
- `filesystem.read`
- `filesystem.search_symbol`
- `topology.read_graph`
- `runtime.read_active_task`

These are not decorative references. They are executable symlinks to runtime-owned handlers.

This matters because repository grounding no longer depends on implicit assistant memory or broad context inheritance. It depends on explicit surfaces the runtime chooses to expose.

### 4.2 Capability payloads are materialized as runtime evidence

The executor now produces `.harness/runtime/capability_payloads/*.json` and injects those payloads into the raw cognition substrate as operational evidence.

This is a major shift. The model is no longer asked to “know the repo.” Instead, it receives deterministic evidence extracted from runtime-executed capability handlers.

That means grounding is becoming payload-driven rather than prompt-driven.

### 4.3 The runtime owns artifact framing

The executor emits normalized JSON payloads and the runtime frames the final artifact with:

- `AEGIS_ARTIFACT_BEGIN`
- `AEGIS_ARTIFACT_END`

This separation is important because framing is now runtime-owned, not model-owned.

### 4.4 The raw substrate is now distinct from aider semantics

The raw cognition substrate was separated from aider-style editing semantics. It now behaves as a bounded readonly cognition substrate that:

- uses the NVIDIA OpenAI-compatible endpoint;
- accepts runtime-grounded payloads;
- extracts strict JSON content;
- validates provider response;
- avoids assistant-style editing behavior.

This is essential because analysis modes should not inherit mutation-oriented cognition.

### 4.5 Worktree topology is now distinct from runtime authority

The runtime now remains outside the worktree as the sovereign authority, while the worktree is treated as a bounded operational surface.

This distinction was one of the most important topology corrections. The runtime does not become “inside” the disposable execution boundary. It creates and governs the boundary from outside it.

That is the correct separation for a deterministic runtime.

---

## 5. Current Architecture by Layer

### 5.1 Governance Layer

**Primary files:**
- `AGENTS.md`
- `.harness/architecture_graph.json`

This layer now expresses the constitution of the system:

- runtime sovereignty;
- capability-grounded execution;
- explicit grounding;
- capability-defined authority;
- disposable execution;
- explicit persistence;
- ephemeral continuity.

The governance layer is no longer just philosophical. It matches the runtime topology that is actually being exercised.

### 5.2 Runtime Layer

**Primary file:**
- `runtime_aegis.sh`

This is the sovereign orchestration authority.

It now handles:

- validation of required files and directories;
- worktree creation and cleanup;
- runtime state initialization;
- capability environment reset;
- capability payload cleanup;
- mode lifecycle execution;
- artifact presence checking;
- runtime continuity promotion.

The runtime now explicitly distinguishes:
- runtime authority;
- execution surfaces;
- transient operational state.

### 5.3 Executor Layer

**Primary file:**
- `scripts/execute_mode.sh`

This file is now the protocol VM and capability payload injector.

It:

- resolves mode topology from config;
- materializes capability environments;
- executes capability handlers;
- writes capability payloads;
- injects payload grounding into the substrate;
- routes to raw or aider substrates;
- validates final JSON payloads;
- emits runtime-framed artifacts.

The executor is no longer a generic wrapper. It is a protocol boundary and evidence injector.

### 5.4 Capability Layer

**Primary files:**
- `scripts/capabilities/**/*.sh`

These scripts are runtime-owned capability surfaces.

They now emit deterministic JSON with a normalized envelope shape and represent explicit authority surfaces. They are no longer just shell helpers.

### 5.5 Substrate Layer

**Primary file:**
- `scripts/substrates/raw_llm.sh`

This is now the bounded readonly cognition substrate.

It:

- calls the provider directly;
- uses strict provider settings;
- requests JSON responses;
- validates provider output;
- extracts final JSON payloads;
- avoids aider semantics.

This is the main substrate for analysis modes.

### 5.6 Configuration Layer

**Primary file:**
- `.harness/config.sh`

This file now acts as a declarative capability registry and runtime topology source.

It centralizes:

- model configuration;
- provider configuration;
- mode-to-substrate mapping;
- mode capability envelopes;
- capability handler registry;
- grounding defaults;
- runtime directory topology;
- protocol flags.

This is no longer just a settings file. It is the declarative source of operational topology.

---

## 6. What Changed Most Recently

The most recent phase of work converged on a narrower but stronger runtime design.

The key shifts were:

1. `runtime_aegis.sh` became the lifecycle authority.
2. `scripts/execute_mode.sh` became the protocol VM and capability payload injector.
3. `.harness/config.sh` became the declarative capability registry and runtime topology source.
4. `AGENTS.md` was updated to explicitly define capability-grounded execution.
5. The mode contracts in `.skills/*.md` were simplified so each file describes only its bounded responsibility.
6. `scripts/capabilities/*` were standardized as executable JSON-emitting surfaces.
7. `scripts/substrates/raw_llm.sh` was separated from aider semantics and hardened for deterministic provider interaction.
8. `active_task.md` became ephemeral runtime continuity state.
9. Runtime authority was separated from worktree execution surface.
10. Capability payloads became the grounding surface for cognition.

These changes moved the system from “well-written prompts” into a runtime protocol with explicit mechanical constraints.

---

## 7. Why the Current Design Is Better Than the Previous One

### 7.1 It removes hidden authority

Before, authority was easy to blur:
- prompts contained too much instruction;
- executor responsibilities were mixed;
- grounding was textual and implicit;
- repository awareness could leak into assistant-style cognition.

Now authority is explicit:
- runtime owns orchestration;
- executor owns protocol;
- capabilities bound authority;
- payloads ground cognition.

### 7.2 It reduces architecture drift

When a runtime is prompt-heavy, it drifts easily into assistant behavior or semantics that are not actually intended.

The current design reduces drift because it gives each layer a narrow, mechanical role:

- runtime = orchestration;
- executor = protocol;
- capability = evidence surface;
- substrate = bounded cognition;
- config = declarative topology.

### 7.3 It makes grounding observable

Grounding is no longer “whatever the model remembers” or “whatever context was passed.”

It is now visible in:
- `.harness/runtime/capability_env/`
- `.harness/runtime/capability_payloads/`
- `.harness/architecture_graph.json`
- runtime-produced artifacts

That is a major improvement in epistemic clarity.

### 7.4 It separates readonly cognition from mutation cognition

The raw substrate no longer inherits aider semantics. This is critical because analysis modes must not behave like mutation-oriented coding sessions.

That separation makes the system much more trustworthy and easier to reason about.

---

## 8. What Was Demonstrated in Practice

The following behaviors were observed during execution and matter architecturally:

### 8.1 Discovery mode now executes through the full runtime pipeline

The runtime:
- creates a detached worktree;
- materializes capability environment;
- executes capability handlers;
- writes capability payloads;
- routes to raw substrate;
- emits a framed artifact.

That is the full runtime loop.

### 8.2 Capability handlers return deterministic JSON

Handlers such as:
- `filesystem.read`
- `filesystem.list_tree`
- `filesystem.search_symbol`
- `topology.read_graph`
- `runtime.read_active_task`

return JSON payloads with explicit fields such as:

- `success`
- `capability`
- `classification`
- `payload`
- `error`

That envelope shape is important because it keeps capability surfaces mechanically parseable.

### 8.3 Provider interaction now works when configured correctly

The provider endpoint and model were verified to work when using the correct NVIDIA OpenAI-compatible endpoint and model identifier.

This confirmed that the remaining issues were not architectural but integration-related.

### 8.4 Runtime errors became meaningful and localized

Earlier failures often looked like architecture failures. Now failures are more clearly local:

- worktree cleanup issues;
- provider transport issues;
- payload extraction issues;
- array resolution bugs;
- artifact framing failures.

That is a sign of a healthy architecture. The remaining failures are implementation bugs, not topology confusion.

---

## 9. Current Strengths

The current system now has:

- explicit authority separation;
- runtime-owned lifecycle;
- deterministic execution boundaries;
- capability environments as executable surfaces;
- runtime-materialized grounding evidence;
- protocol-framed artifacts;
- substrate separation;
- disposable worktrees;
- ephemeral continuity;
- centralized topology declaration;
- bounded readonly cognition;
- mutation authorized only where intended.

These are the ingredients of a real bounded runtime, not just a set of prompts.

---

## 10. Current Limits

The runtime is now structurally coherent, but there are still a few operational hardening tasks left.

### 10.1 Provider integration hardening
The raw substrate now works with the right model and endpoint, but this layer should remain carefully validated because provider behavior and response formatting are a frequent source of failures.

### 10.2 Worktree cleanup robustness
The runtime already handles worktrees better than before, but this remains a fragile area in many git-based runtimes and should continue to be monitored.

### 10.3 Mutation substrate hardening
The mutation path still relies on aider. That is acceptable for now, but it should remain bounded and explicit.

### 10.4 Capability coercion
Capabilities are exposed and executed, but the next maturity step is more explicit enforcement of which surfaces are visible and how they are consumed.

### 10.5 Structured evidence consumption in modes
The analysis modes now receive payload grounding, but future refinement could make the use of those payloads even more explicit and machine-structured.

---

## 11. Why This Design Is the Correct Direction

This direction is correct because it preserves the strongest property of the system:

> runtime sovereignty with explicit capability grounding.

That gives the system:

- lower ambiguity;
- better auditability;
- stronger containment;
- deterministic lifecycle behavior;
- clearer failure modes;
- better long-term maintainability.

It also avoids the common failure mode of modern AI tooling:
- turning everything into a loosely coupled assistant wrapper around hidden prompt state.

Aegis is moving away from that pattern.

---

## 12. Final Architectural Position

Aegis Harness is now much closer to a coherent bounded runtime than a conventional assistant framework.

The current position is:

- the runtime governs;
- the executor coerces;
- the modes reason;
- the capabilities expose authority;
- the substrate consumes evidence;
- persistence remains explicit;
- continuity remains ephemeral;
- grounding remains runtime-owned;
- repository awareness is capability-bound.

That is the system as it exists now.

It is not a theoretical design. It is an operational architecture that has already been partially proven through execution.