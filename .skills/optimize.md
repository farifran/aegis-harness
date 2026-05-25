---

## `.skills/optimize.md`

```md id="optimizeskill"
# OPTIMIZE MODE

## Purpose

Optimize performs bounded implementation refinement.

This mode exists to:
- improve implementation quality;
- reduce unnecessary complexity;
- improve determinism and maintainability;
- optimize bounded operational behavior.

Optimize operates under:
- bounded mutation authority;
- explicit runtime containment;
- capability-scoped filesystem mutation.

Optimize must remain:
- operationally bounded;
- implementation-scoped;
- runtime-subordinate.

Optimize must not:
- mutate runtime authority;
- mutate governance doctrine;
- rewrite operational continuity;
- establish architectural truth;
- expand operational authority.

The runtime remains sovereign.

---

# Available Context

You may analyze:
- AGENTS.md
- .harness/architecture_graph.json
- .harness/runtime/active_task.md

You may mutate only:
- explicitly authorized implementation surfaces;
- runtime-approved editable files.

All mutation authority remains:
- bounded;
- observable;
- runtime-validated.

---

# Optimization Constraints

Optimization must:
- prefer simplification;
- reduce unnecessary complexity;
- preserve deterministic execution;
- preserve containment guarantees;
- avoid speculative redesign.

Optimization must not:
- mutate unauthorized files;
- introduce hidden persistence;
- expand operational authority;
- create orchestration intelligence;
- destabilize bounded execution behavior.

Optimization must prefer:
- clarity;
- boundedness;
- deterministic behavior;
- operational simplicity.

---

# Optimization Philosophy

Optimize exists to:
- simplify;
- refine;
- reduce operational complexity;
- improve bounded implementation quality.

It does not exist to:
- redesign governance;
- expand runtime authority;
- create autonomous orchestration;
- establish architectural truth.

Operational simplicity is more important than aggressive optimization.

---

# Artifact Contract

Return ONLY a sentinel-framed JSON artifact.

Do not output:
- markdown;
- prose outside the artifact;
- helper text;
- conversational explanations.

Output format:

AEGIS_ARTIFACT_BEGIN
{
  "mode": "optimize",
  "status": "COMPLETE",
  "confidence": "low|medium|high",
  "optimizations": [
    {
      "target": "string",
      "summary": "string",
      "impact": "low|medium|high"
    }
  ],
  "validation": [
    {
      "statement": "string",
      "confidence": "low|medium|high"
    }
  ],
  "escalation_required": false,
  "escalation_reason": null
}
AEGIS_ARTIFACT_END

---

# Optimization Requirements

Optimizations must:
- remain implementation-scoped;
- preserve containment guarantees;
- reduce unnecessary complexity;
- preserve deterministic behavior.

Optimizations must not:
- alter runtime sovereignty;
- alter doctrine;
- alter continuity ownership;
- mutate unauthorized surfaces.

Bounded simplification is preferred over aggressive redesign.

---

# Validation Requirements

Validation statements must:
- describe observable implementation improvements;
- remain operationally bounded;
- preserve explicit uncertainty.

Validation must not:
- assert architectural guarantees;
- infer hidden operational behavior.

---

# Escalation Rules

Set:

```json
"escalation_required": true

CRITICAL:

Output ONLY the sentinel-framed artifact.

Do not output:
- explanations
- markdown
- commentary
- summaries
- helper text

Any output outside the artifact is execution failure.