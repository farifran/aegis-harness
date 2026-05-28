
# Aegis LLM Setting

cat >> ~/.bashrc <<'EOF'

export OPENAI_API_BASE="https://integrate.api.nvidia.com/v1"

export OPENAI_API_KEY="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"

EOF

source ~/.bashrc

echo $OPENAI_API_BASE

curl https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model":"meta/llama-3.3-70b-instruct",
    "messages":[
      {
        "role":"user",
        "content":"Reply only with OK"
      }
    ],
    "temperature":0
  }'

timeout 20 aider \
  --model openai/meta/llama-3.3-70b-instruct \
  --message "Reply ONLY with: OK" \
  --yes-always \
  --no-show-model-warnings \
  --no-stream \
  --no-pretty \
  --map-tokens 0 \
  --no-git \
  --exit

# Aegis Harness

Aegis Harness is a bounded, deterministic AI execution runtime designed to separate cognition, orchestration, continuity, persistence, and mutation authority. The system is built around explicit authority boundaries, disposable execution environments, capability-grounded grounding, and protocol-enforced artifacts.

## What Aegis Is

Aegis treats AI systems as bounded execution units rather than autonomous agents.

The core goal is to ensure that:

- the runtime governs execution,
- modes produce bounded cognition,
- capabilities define authority,
- persistence remains explicit,
- continuity remains ephemeral,
- execution is mechanically observable.

This architecture intentionally rejects hidden persistence, implicit governance, conversational execution topology, and assistant-style repository inheritance.

## Current Architecture

Aegis is organized around a small set of clearly separated responsibilities:

| Layer | Responsibility |
|---|---|
| `AGENTS.md` | Governance constitution and operating principles |
| `runtime_aegis.sh` | Runtime orchestration, worktree lifecycle, capability lifecycle, cleanup |
| `scripts/execute_mode.sh` | Protocol virtual machine, capability environment injection, payload grounding |
| `scripts/substrates/raw_llm.sh` | Readonly cognition substrate for analysis modes |
| `scripts/capabilities/*` | Runtime-owned capability handlers |
| `.harness/config.sh` | Central capability registry and runtime topology |
| `.skills/*.md` | Mode contracts |
| `.harness/architecture_graph.json` | Capability-readable topology |

## Execution Model

Aegis operates through disposable git worktrees and runtime-owned capability environments.

The runtime:

1. validates topology,
2. creates an isolated worktree,
3. materializes capability environments,
4. executes capability handlers,
5. materializes capability payloads,
6. injects runtime-owned grounding evidence,
7. executes the selected mode substrate,
8. validates the resulting artifact,
9. promotes or discards ephemeral continuity,
10. cleans up transient state.

The execution model is intentionally deterministic and protocol-oriented.

## Capability Topology

Capabilities are not generic tools. They are runtime-owned authority surfaces.

Examples include:

- `filesystem.read`
- `filesystem.list_tree`
- `filesystem.search_symbol`
- `git.status`
- `git.diff`
- `topology.read_graph`
- `runtime.read_active_task`

Capabilities are exposed through executable handler scripts under `scripts/capabilities/`, and the runtime materializes them into `.harness/runtime/capability_env/` during execution.

## Modes

Aegis currently defines the following modes:

### Analysis modes
- `discovery`
- `forensics`
- `validation`
- `adversarial`

These modes are readonly and operate on explicit capability payloads.

### Mutation modes
- `repair`
- `optimize`

These modes are bounded mutation modes and may operate only on explicitly authorized surfaces.

## Core Design Principles

Aegis is built around the following principles:

- **Runtime sovereignty** â the runtime owns orchestration and lifecycle.
- **Capability-based authority** â modes consume capabilities; they do not self-authorize.
- **Explicit grounding** â repository awareness is runtime-exposed, not implicit.
- **Disposable execution** â worktrees and runtime state are ephemeral.
- **Protocol enforcement** â outputs are validated mechanically.
- **KISS** â minimize complexity, avoid framework drift, and preserve operational clarity.

## Requirements

Aegis expects a shell environment with:

- `bash`
- `git`
- `jq`
- `curl`
- `python3`

It also expects access to a compatible OpenAI-style endpoint.

## Provider Configuration

The runtime is configured through environment variables and `.harness/config.sh`.

Typical provider settings:

```bash
export OPENAI_API_KEY="..."
export OPENAI_API_BASE="https://integrate.api.nvidia.com/v1"
```

The current runtime has been validated with NVIDIAâs OpenAI-compatible endpoint and a `meta/llama-3.3-70b-instruct` family model.

## Quick Start

Run the full runtime:

```bash
bash runtime_aegis.sh
```

Run a specific mode directly:

```bash
bash scripts/execute_mode.sh   ".skills/discovery.md"   "discovery"   ".harness/runtime/active_task.md"
```

Execute a capability handler directly:

```bash
bash .harness/runtime/capability_env/filesystem.read AGENTS.md
```

## Repository Structure

```text
.
âââ AGENTS.md
âââ runtime_aegis.sh
âââ scripts/
â   âââ execute_mode.sh
â   âââ substrates/
â   â   âââ raw_llm.sh
â   âââ capabilities/
â       âââ filesystem/
â       âââ git/
â       âââ runtime/
â       âââ topology/
âââ .harness/
â   âââ architecture_graph.json
â   âââ config.sh
â   âââ runtime/
âââ .skills/
âââ docs/
```

## Artifact Contract

Modes emit sentinel-framed JSON artifacts.

The runtime validates:

- framing integrity,
- JSON validity,
- mode identity,
- protocol compliance.

Artifacts are treated as machine-readable execution outputs, not conversational responses.

## Operational Notes

The current design intentionally avoids:

- hidden memory systems,
- autonomous orchestration layers,
- implicit persistence,
- assistant-style repository inheritance,
- premature framework expansion.

The architecture is currently optimized for:

- deterministic execution,
- explicit authority,
- runtime-owned grounding,
- bounded cognition,
- disposable runtime state.

## Current Status

Aegis is now operating as a capability-grounded runtime with:

- runtime sovereignty,
- explicit capability environments,
- payload-based grounding,
- protocol-enforced execution,
- disposable worktrees,
- bounded readonly cognition for analysis modes,
- bounded mutation surfaces for mutation modes.

The remaining work should focus on operational hardening rather than architectural expansion.

## License

See `LICENSE.md` for licensing information.
