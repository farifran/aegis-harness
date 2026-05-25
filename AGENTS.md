## Executor Topology Separation

The system distinguishes between:

- analysis-only cognition topology;
- mutation-authorized cognition topology.

This distinction is structural.

Analysis-only modes:
- discovery
- forensics
- validation
- adversarial

must remain:
- read-only;
- non-materializing;
- stdout-only;
- persistence-independent.

These modes must NEVER:
- create files;
- create directories;
- apply patches;
- materialize artifacts;
- persist outputs;
- mutate repository state.

Artifacts for these modes exist ONLY in stdout.

Mutation-authorized modes:
- repair
- optimize

may mutate ONLY:
- explicitly authorized editable surfaces;
- runtime-approved mutation boundaries.

Mutation authority never implies:
- persistence authority;
- governance authority;
- runtime authority.

The runtime remains the sole owner of:
- persistence;
- continuity;
- recovery state;
- filesystem authority.

Containment must remain mechanically enforced.

Prompt alignment alone is insufficient as a security or authority boundary.

The system therefore relies on:
- runtime validation;
- filesystem materialization detection;
- mutation boundary validation;
- disposable sandbox isolation.

Executor topology matters.

Coding-oriented executors naturally induce:
- edit cognition;
- patch generation;
- filesystem materialization behavior.

The runtime must therefore explicitly enforce:
- capability boundaries;
- persistence boundaries;
- mutation boundaries;
- containment integrity.

Artifacts are transient runtime outputs.

Artifacts are NOT persistent repository objects unless explicitly runtime-authorized.