#!/usr/bin/env bash
#
# Creates folders at CWD for saving models in.
# Relies on `kohya_ss` naming conventions for training directory.

set -e

mkdir -p ./repos
mkdir -p ./checkpoints
mkdir -p ./loras
mkdir -p ./embeddings
mkdir -p ./upscale_models
mkdir -p ./controlnet
mkdir -p ./depth-maps
