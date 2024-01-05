#!/usr/bin/env bash
#
# Lists keywords from caption files in CWD recursively.

set -e

find . -type f -name "*.txt" \
| while read -r path; do
    cat "${path}" \
    | while read -r -d "," keyword; do
        echo "${keyword}"
      done
  done \
| sort --uniq
