#!/usr/bin/env bash
#
# Cleans up some trash from training directory.

set -e

find . -name "*.npz" \
| while read -r path; do
    rm -f "${path}"
  done

rm -rf logs
mkdir -p logs
