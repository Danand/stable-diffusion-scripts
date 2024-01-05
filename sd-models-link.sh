#!/usr/bin/env bash
#
# Links all models from CWD to corresponding directories in UI wrappers for Stable Diffusion.

function link() {
  if [ ! -d "$1" ]; then
    return 0
  fi

  mkdir -p "$2"

  local source_dir
  source_dir="$(realpath "$1")"

  local target_dir
  target_dir="$(realpath "$2")"

  local ext="$3"

  pushd "${source_dir}" > /dev/null || return 2

  for file_name in *.${ext}; do
    if [ "${file_name}" == "*.${ext}" ]; then
      continue
    fi

    local symlink_source="${source_dir}/${file_name}"
    local symlink_destination="${target_dir}/${file_name}"

    ln -sf "${symlink_source}" "${symlink_destination}"

    echo "Symlink created: '${symlink_destination}' -> '${symlink_source}'"
  done

  popd > /dev/null

  find "${target_dir}" -type l \
  | while read -r file_path; do
      if [ ! -e "${file_path}" ]; then
        rm -f "${file_path}"
        echo "Removed broken symlink: '${file_path}'"
      fi
    done
}

function link-dirs() {
  local source_parent_dir
  source_parent_dir="$(realpath "$1")"

  local target_parent_dir
  target_parent_dir="$(realpath "$2")"

  find "${source_parent_dir}" -depth 1 -type d \
  | while read -r dir; do
      local symlink_source
      symlink_source="$(realpath "${dir}")"

      local symlink_destination
      symlink_destination="${target_parent_dir}/$(basename "${dir}")"

      ln -sf "${symlink_source}" "${symlink_destination}"

      echo "Symlink created: '${symlink_destination}' -> '${symlink_source}'"
    done
}

set -e

if [ -z "${COMFYUI_PATH}" ]; then
  COMFYUI_PATH="${HOME}/ComfyUI"
fi

if [ -d "${COMFYUI_PATH}" ]; then
  link ./checkpoints "${COMFYUI_PATH}/models/checkpoints" "ckpt"
  link ./checkpoints "${COMFYUI_PATH}/models/checkpoints" "safetensors"
  link ./loras "${COMFYUI_PATH}/models/loras" "safetensors"
  link ./embeddings "${COMFYUI_PATH}/models/embeddings" "pt"
  link ./embeddings "${COMFYUI_PATH}/models/embeddings" "safetensors"
  link ./upscale_models "${COMFYUI_PATH}/models/upscale_models" "safetensors"
  link ./upscale_models "${COMFYUI_PATH}/models/upscale_models" "pt"
  link ./upscale_models "${COMFYUI_PATH}/models/upscale_models" "pth"
fi

if [ -z "${A1111_PATH}" ]; then
  A1111_PATH="${HOME}/stable-diffusion-webui"
fi

if [ -d "${A1111_PATH}" ]; then
  link ./checkpoints "${A1111_PATH}/models/Stable-diffusion" "ckpt"
  link ./checkpoints "${A1111_PATH}/models/Stable-diffusion" "safetensors"
  link ./vae "${A1111_PATH}/models/VAE" "safetensors"
  link ./loras "${A1111_PATH}/models/Lora" "safetensors"
  link ./embeddings "${A1111_PATH}/embeddings" "pt"
  link ./embeddings "${A1111_PATH}/embeddings" "safetensors"
  link ./upscale_models "${A1111_PATH}/models/ESRGAN" "safetensors"
  link ./upscale_models "${A1111_PATH}/models/ESRGAN" "pt"
  link ./upscale_models "${A1111_PATH}/models/ESRGAN" "pth"
  link ./repos/ControlNet-v1-1 "${A1111_PATH}/extensions/sd-webui-controlnet/models" "pth"
  link ./repos/sd_control_collection "${A1111_PATH}/extensions/sd-webui-controlnet/models" "safetensors"
  link-dirs ./depth-maps "${A1111_PATH}/extensions/sd-webui-depth-lib/maps"
fi
