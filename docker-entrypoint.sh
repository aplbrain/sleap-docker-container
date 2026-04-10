#!/usr/bin/env bash
set -euo pipefail

build_input_path() {
  local relative_path="$1"
  printf '%s/%s' "${INPUT_DIR}" "${relative_path}"
}

build_output_path() {
  local relative_path="$1"
  printf '%s/%s' "${OUTPUT_DIR}" "${relative_path}"
}

build_model_input_path() {
  local relative_path="$1"
  local model_input_dir="${MODEL_INPUT_DIR:-${INPUT_DIR}}"
  printf '%s/%s' "${model_input_dir}" "${relative_path}"
}

if [[ -n "${RUN_MODE:-}" ]]; then
  : "${INPUT_DIR:?INPUT_DIR must be set}"
  : "${OUTPUT_DIR:?OUTPUT_DIR must be set}"

  mkdir -p "${OUTPUT_DIR}"

  case "${RUN_MODE}" in
    train)
      : "${CONFIG:?CONFIG must be set for RUN_MODE=train}"
      set -- train --config "$(build_input_path "${CONFIG}")"
      ;;
    track)
      : "${DATA_PATH:?DATA_PATH must be set for RUN_MODE=track}"
      : "${MODEL_PATHS:?MODEL_PATHS must be set for RUN_MODE=track}"
      : "${O:?O must be set for RUN_MODE=track}"
      set -- \
        track \
        --data_path "$(build_input_path "${DATA_PATH}")" \
        --model_paths "$(build_model_input_path "${MODEL_PATHS}")" \
        -o "$(build_output_path "${O}")"
      ;;
    *)
      echo "Unsupported RUN_MODE: ${RUN_MODE}. Expected 'train' or 'track'." >&2
      exit 1
      ;;
  esac
fi

exec sleap-nn "$@"
