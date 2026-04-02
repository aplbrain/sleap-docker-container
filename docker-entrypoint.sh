#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${INPUT_DIR:-}" || -n "${OUTPUT_DIR:-}" ]]; then
  : "${INPUT_DIR:?INPUT_DIR must be set}"
  : "${OUTPUT_DIR:?OUTPUT_DIR must be set}"

  mkdir -p "${OUTPUT_DIR}"
  if [[ ! -f "${INPUT_DIR}/sleap_config.yaml" ]]; then
    echo "Expected config at ${INPUT_DIR}/sleap_config.yaml" >&2
    exit 1
  fi
  set -- train --config "${INPUT_DIR}/sleap_config.yaml"
fi

exec sleap-nn "$@"
