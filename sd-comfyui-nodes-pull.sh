#/usr/bin/env bash
#
# Updates custom nodes of ComfyUI.

set -e

if [ -z "${COMFYUI_PATH}" ]; then
  COMFYUI_PATH="${HOME}/ComfyUI"
fi

find "${COMFYUI_PATH}/custom_nodes" \
  -type d \
  -name ".git" \
| while read -r git_dir; do
    custom_node_dir="$(dirname "${git_dir}")"
    custom_node_name="$(basename "${custom_node_dir}")"

    echo
    echo "Updating ${custom_node_name}"

    pushd "$(dirname "${git_dir}")" > /dev/null

    git pull

    popd > /dev/null
  done
