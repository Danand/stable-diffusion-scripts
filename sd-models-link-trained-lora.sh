#!/usr/bin/env bash
#
# Links all trained LoRA models from CWD to corresponding directories in UI wrappers for Stable Diffusion.
# Relies on `kohya_ss` naming conventions for training directory.

function link() {
  local target_dir
  target_dir="$(realpath "$1")"

  find . -maxdepth 1 -name "output*" \
  | while read -r output_dir; do
      local suffix
      suffix="$(basename "${output_dir}" | cut -d "-" -f 2-)"

      if [ "${suffix}" == "output" ]; then
        suffix=""
      else
        suffix="-${suffix}"
      fi

      local source_dir
      source_dir="$(realpath "${output_dir}")"

      find "${output_dir}" -maxdepth 1 -type f -name "*.safetensors" \
      | while read -r file_path; do
          local file_name="$(basename ${file_path})"
          local file_name_without_ext="$(basename ${file_path} ".safetensors")"
          local file_name_symlink="${file_name_without_ext}${suffix}.safetensors"

          local symlink_source="${source_dir}/${file_name}"
          local symlink_destination="${target_dir}/${file_name_symlink}"

          ln -sf "${symlink_source}" "${symlink_destination}"

          echo "Symlink created: '${symlink_destination}' -> '${symlink_source}'"
        done
    done
}

set -e

if [ -z "${COMFYUI_PATH}" ]; then
  COMFYUI_PATH="${HOME}/ComfyUI"
fi

if [ -d "${COMFYUI_PATH}" ]; then
  link "${COMFYUI_PATH}/models/loras"
fi

if [ -z "${A1111_PATH}" ]; then
  A1111_PATH="${HOME}/stable-diffusion-webui"
fi

if [ -d "${A1111_PATH}" ]; then
  link "${A1111_PATH}/models/Lora"
fi
