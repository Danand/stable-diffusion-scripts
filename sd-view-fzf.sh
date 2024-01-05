#!/usr/bin/env bash
#
# Reads metadata from picture generated with ComfyUI.
# Requires `fzf` to be installed.

function __read_workflow_metadata() {
  local path="$1"

  workflow="$(\
    exiftool \
      -s -s -s \
      -Prompt "${path}" \
    | jq \
  )"

  echo "${workflow}" | grep "\"seed\""
  echo "${workflow}" | grep "\"steps\""
  echo "${workflow}" | grep "\"cfg\""
  echo "${workflow}" | grep "\"sampler_name\""
  echo "${workflow}" | grep "\"scheduler\""
  echo "${workflow}" | grep "\"denoise\""
  echo
  echo "${workflow}" | grep "lora_name" -A 3
  echo
  echo "${workflow}" | grep "CLIPTextEncode" -B 6

  if [[ "${OSTYPE}" == "darwin"* ]]; then
    chmod 777 "${path}" # HACK: Allow to open file with `Preview`:
    open -g -a Preview "${path}"
  fi
}

set -e

export -f __read_workflow_metadata

image_path="$( \
  find \
    . \
    -mindepth 1 \
    -maxdepth 1 \
    -type f \
    -name "*.png" \
  | sort \
  | fzf \
    --no-sort \
    --tac \
    --preview-window "up:77%,wrap" \
    --preview "__read_workflow_metadata '{}'" \
)"

if [ -z "${image_path}" ]; then
  exit 0
fi

exiftool \
  -s -s -s \
  -Prompt "${image_path}" \
| jq
