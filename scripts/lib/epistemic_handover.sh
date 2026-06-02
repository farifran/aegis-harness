#!/usr/bin/env bash

epistemic_state_schema_filter() {
  cat <<'EOF'
type == "object"
and ((keys | sort) == [
  "attention_reason",
  "attention_scope",
  "next_attention_targets"
])
and (.next_attention_targets | type == "array")
and (.attention_scope | type == "string" and length > 0)
and (.attention_reason | type == "string" and length > 0)
and (
  [.next_attention_targets[]] | all(type == "string")
)
EOF
}

epistemic_handover_schema_filter() {
  cat <<'EOF'
type == "object"
and ((keys | sort) == [
  "artifact_snapshot",
  "epistemic_state"
])
and (
  (.artifact_snapshot == null)
  or (.artifact_snapshot | type == "object")
)
and (
  .epistemic_state
  | (
      type == "object"
      and ((keys | sort) == [
        "attention_reason",
        "attention_scope",
        "next_attention_targets"
      ])
      and (.next_attention_targets | type == "array")
      and (.attention_scope | type == "string" and length > 0)
      and (.attention_reason | type == "string" and length > 0)
      and (
        [.next_attention_targets[]] | all(type == "string")
      )
    )
)
EOF
}

handover_schema_is_valid() {

  local handover_file="$1"

  jq -e "$(epistemic_handover_schema_filter)" "${handover_file}" >/dev/null 2>&1
}

validate_epistemic_state_json() {

  local epistemic_state_json="$1"

  printf '%s' "${epistemic_state_json}" \
    | jq -e "$(epistemic_state_schema_filter)" >/dev/null 2>&1
}

write_empty_epistemic_handover_state_json() {
  printf '%s' '{"next_attention_targets":[],"attention_scope":"none","attention_reason":"no active attention"}'
}

epistemic_state_json_from_handover() {

  local handover_file="$1"

  if handover_schema_is_valid "${handover_file}"; then
    jq -c '.epistemic_state' "${handover_file}"
    return 0
  fi

  return 1
}

artifact_snapshot_json_from_handover() {

  local handover_file="$1"

  if handover_schema_is_valid "${handover_file}"; then
    jq -c '.artifact_snapshot' "${handover_file}"
    return 0
  fi

  return 1
}