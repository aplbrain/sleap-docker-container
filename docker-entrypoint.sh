#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${INPUT_DIR:-}" || -n "${OUTPUT_DIR:-}" ]]; then
  : "${INPUT_DIR:?INPUT_DIR must be set}"
  : "${OUTPUT_DIR:?OUTPUT_DIR must be set}"

  mkdir -p "${OUTPUT_DIR}"
  tmp_dir="$(mktemp -d)"
  staged_config="${tmp_dir}/sleap_config.yaml"

  if [[ ! -f "${INPUT_DIR}/sleap_config.yaml" ]]; then
    echo "Expected config at ${INPUT_DIR}/sleap_config.yaml" >&2
    exit 1
  fi

  awk -v input_dir="${INPUT_DIR}" -v output_dir="${OUTPUT_DIR}" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }

    /^[[:space:]]*train_labels_path:[[:space:]]*$/ { in_train=1; in_val=0; print; next }
    /^[[:space:]]*val_labels_path:[[:space:]]*$/ { in_train=0; in_val=1; print; next }
    /^[[:space:]]*ckpt_dir:[[:space:]]*/ {
      in_train=0
      in_val=0
      indent = substr($0, 1, match($0, /ckpt_dir:/) - 1)
      print indent "ckpt_dir: " output_dir "/models"
      next
    }

    in_train && /^[[:space:]]*-[[:space:]]*/ {
      indent = substr($0, 1, match($0, /-/) - 1)
      value = trim(substr($0, match($0, /-[[:space:]]*/) + RLENGTH))
      print indent "- " input_dir "/" value
      next
    }

    in_val && /^[[:space:]]*-[[:space:]]*/ {
      indent = substr($0, 1, match($0, /-/) - 1)
      value = trim(substr($0, match($0, /-[[:space:]]*/) + RLENGTH))
      print indent "- " input_dir "/" value
      next
    }

    !/^[[:space:]]*-[[:space:]]*/ {
      in_train=0
      in_val=0
    }

    { print }
  ' "${INPUT_DIR}/sleap_config.yaml" > "${staged_config}"

  cd "${tmp_dir}"

  new_args=()
  skip_next=0
  config_replaced=0

  for arg in "$@"; do
    if [[ "${skip_next}" -eq 1 ]]; then
      skip_next=0
      continue
    fi

    if [[ "${arg}" == "--config" ]]; then
      new_args+=("--config" "${staged_config}")
      skip_next=1
      config_replaced=1
      continue
    fi

    new_args+=("${arg}")
  done

  if [[ "${config_replaced}" -eq 0 ]]; then
    new_args+=("--config" "${staged_config}")
  fi

  set -- "${new_args[@]}"
fi

exec sleap-nn "$@"
