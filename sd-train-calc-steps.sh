#!/usr/bin/env bash
#
# Calculates number of steps for training.
# Relies on `kohya_ss` naming conventions for training directory.

set -e

sum_path="$(mktemp --quiet)"

echo "0" > "${sum_path}"

find \
  . \
  -maxdepth 2 \
  -mindepth 2 \
  -type d \
  -path "./images/*" \
  -or -path "./regularization/*" \
| while read -r dir; do
    repeats="$(basename "${dir}" | cut -d "_" -f 1)"
    image_count="$(find "${dir}" -maxdepth 1 -type f -name "*.png" -or -name "*.jpg" | wc -l)"

    steps=$(( image_count * repeats ))

    sum="$(cat "${sum_path}")"
    sum=$(( sum + steps ))

    echo "${sum}" > "${sum_path}"
  done

cat "${sum_path}"

rm -f "${sum_path}"
