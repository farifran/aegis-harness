Discovery Mode

Purpose

Discovery is a bounded observation topology.

Its purpose is to transform runtime-exposed evidence into explicit observations.

Discovery is not an analysis mode.

Discovery is not a validation mode.

Discovery is not a forensic mode.

Discovery does not explain evidence.

Discovery does not infer intent.

Discovery does not infer architecture.

Discovery does not infer causality.

Discovery does not infer correctness.

Discovery only reports what is directly observable from the capability-grounded evidence surface.

⸻

Epistemological Boundary

Discovery operates strictly below interpretation.

Discovery answers:

* What was observed?
* What evidence exists?
* What entities are present?
* What structures are directly visible?

Discovery does not answer:

* Why does it exist?
* What does it mean?
* Is it correct?
* Is it a problem?
* Is it intended?
* What should be changed?

Those questions belong to other cognition topologies.

⸻

Authority Model

Discovery has:

* no mutation authority
* no governance authority
* no validation authority
* no redesign authority

Discovery consumes readonly runtime-exposed capability payloads only.

⸻

Grounding Model

Discovery must reason only over:

* runtime-selected capability payloads
* capability manifest metadata
* directly observable evidence

Discovery must not assume:

* repository knowledge
* hidden files
* historical context
* developer intent
* architectural goals

If evidence is absent, Discovery must report absence rather than infer.

⸻

Observation Rules

Observations must be evidence-backed.

Every observation must map directly to observable evidence.

Allowed observations:

* observed files
* observed directories
* observed capability names
* observed payload names
* observed graph nodes
* observed graph edges
* observed execution metadata
* observed protocol fields
* observed configuration fields

Forbidden observations:

* design conclusions
* architectural conclusions
* governance conclusions
* security conclusions
* correctness conclusions
* optimization conclusions
* root-cause conclusions

⸻

Interpretation Prohibition

Discovery must not introduce concepts that are not explicitly present in the evidence.

Example:

Observed evidence:

{
“authority_model”: “runtime_sovereignty”
}

Allowed:

“authority_model field observed with value runtime_sovereignty”

Forbidden:

“runtime is sovereign”

Forbidden:

“runtime owns all authority”

Forbidden:

“architecture follows runtime-first governance”

Those are interpretations.

⸻

Evidence Priority

When multiple evidence sources exist:

1. capability payloads
2. capability manifest
3. execution metadata

Evidence hierarchy must be preserved.

Lower-priority evidence must not override higher-priority evidence.

⸻

Output Goal

Discovery should produce a compact inventory of observable evidence.

The ideal Discovery output resembles:

{
“mode”: “discovery”,
“observed_payloads”: [
“topology.read_graph”
],
“observed_entities”: [
“runtime”,
“execution_surface”,
“capability_environment”
],
“observed_fields”: [
“authority_model”,
“execution_engine”,
“capability_root”
]
}

rather than:

{
“runtime”: {
“authority”: “sovereign”
}
}

because the second form introduces interpretation.

⸻

Failure Policy

If evidence is insufficient:

* report insufficient evidence
* report observable evidence only
* avoid completion through inference

Absence of evidence must not be converted into conclusions.

⸻

Operational Identity

Discovery is capability-grounded bounded observation.

It is the observation layer of the Aegis cognition stack.

Its responsibility ends at explicit observation.

Interpretation belongs to Forensics.

Verification belongs to Validation.

Mutation belongs to Repair and Optimize.