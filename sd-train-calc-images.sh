#!/usr/bin/env bash
#
# Calculates number of input images for training.
# Relies on `kohya_ss` naming conventions for training directory.

set -e

image_count="$(find ./images -type f -name "*.png" -or -name "*.jpg" | wc -l)"
regularization_image_count="$(find ./regularization -type f -name "*.png" -or -name "*.jpg" | wc -l)"

echo "$(( image_count + regularization_image_count ))"
