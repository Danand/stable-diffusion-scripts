#/usr/bin/env bash
#
# Trains LoRA model at CWD.
# Relies on `kohya_ss` naming conventions for training directory.
# Requires `fzf` to be installed.
# Requires `kohya_ss` to be cloned.

set -e

if [ -z "$1" ]; then
  project_path="$(realpath ".")"
else
  project_path="$(realpath "$1")"
fi

project_name="$(basename "${project_path}")"

if [ -z "${KOHYA_SS_PATH}" ]; then
  KOHYA_SS_PATH="${HOME}/kohya_ss"
  echo "\`KOHYA_SS_PATH\` was not found in current environment, using default path: \`${KOHYA_SS_PATH}\`" 1>&2
fi

if [ -z "${SD_MODELS_PATH}" ]; then
  SD_MODELS_PATH="${HOME}/stable-diffusion-models"
  echo "\`SD_MODELS_PATH\` was not found in current environment, using default path: \`${SD_MODELS_PATH}\`" 1>&2
fi

base_model="$( \
  find "${SD_MODELS_PATH}/checkpoints" -type f -name "*.safetensors" \
  | fzf --header "Choose base model" \
)"

training_script="$( \
  find "${KOHYA_SS_PATH}" -maxdepth 1 -type f -name "*train_network*.py" \
  | fzf --header "Choose training script" \
)"

read -er -p "Enter amount of training epochs: " -i "3" epochs_amount
read -er -p "Enter training width: " -i "512" width
read -er -p "Enter training height: " -i "512" height
read -er -p "Enter training seed: " -i "12345" seed
read -er -p "Enter network dim: " -i "128" network_dim
read -er -p "Enter network alpha: " -i "128" network_alpha
read -er -p "Enter learning rate: " -i "0.0001" learning_rate
read -er -p "Enter U-Net learning rate: " -i "0.0001" unet_lr
read -er -p "Enter text encoder learning rate: " -i "5e-5" text_encoder_lr
read -er -p "Enter noise offset: " -i "0.0" noise_offset

sampler="$( \
  (
    echo "ddim"
    echo "pndm"
    echo "lms"
    echo "euler"
    echo "euler_a"
    echo "heun"
    echo "dpm_2"
    echo "dpm_2_a"
    echo "dpmsolver"
    echo "dpmsolver++"
    echo "dpmsingle"
    echo "k_lms"
    echo "k_euler"
    echo "k_euler_a"
    echo "k_dpm_2"
    echo "k_dpm_2_a"
  ) \
  | fzf --header "Choose training script" \
)"

SCRIPT_PATH="$(realpath "${BASH_SOURCE}")"
SCRIPT_DIR="$(realpath "$(dirname "${SCRIPT_PATH}")")"

steps_amount_per_epoch="$(cd "${project_path}" && "${SCRIPT_DIR}/sd-train-calc-steps.sh")"
steps_amount_total="$(( steps_amount_per_epoch * epochs_amount ))"

cd "${KOHYA_SS_PATH}"

source venv/bin/activate

export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

accelerate launch \
  --num_cpu_threads_per_process="8" \
  "${training_script}" \
  --pretrained_model_name_or_path="${base_model}" \
  --train_data_dir="${project_path}/images" \
  --output_dir="${project_path}/output" \
  --logging_dir="${project_path}/logs" \
  --output_name="${project_name}" \
  --resolution="${width},${height}" \
  --seed="${seed}" \
  --lr_scheduler_num_cycles="${epochs_amount}" \
  --network_dim="${network_dim}" \
  --network_alpha="${network_alpha}" \
  --learning_rate="${learning_rate}" \
  --unet_lr="${unet_lr}" \
  --text_encoder_lr="${text_encoder_lr}" \
  --max_train_steps="${steps_amount_total}" \
  --save_model_as="safetensors" \
  --network_module="networks.lora" \
  --no_half_vae \
  --lr_scheduler="cosine_with_restarts" \
  --train_batch_size="1" \
  --save_every_n_epochs="1" \
  --mixed_precision="no" \
  --save_precision="float" \
  --caption_extension=".txt" \
  --cache_latents \
  --cache_latents_to_disk \
  --optimizer_type="AdamW" \
  --max_data_loader_n_workers="0" \
  --gradient_checkpointing \
  --bucket_no_upscale \
  --noise_offset="${noise_offset}" \
  --network_train_unet_only \
  --lowram \
  --sample_sampler="${sampler}"
