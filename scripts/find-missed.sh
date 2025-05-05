#!/bin/bash

set -euo pipefail

function main() {
  printf '' >missed.jsonl

  json_file=versions.json

  php_versions=($(jq -r '.php[]' "$json_file"))
  # platforms=($(jq -r '.platform[]' "$json_file"))
  oses=($(jq -r '.os[]' "$json_file"))

  ext_names=($(jq -r 'keys_unsorted[]' <<<"$(jq '.ext' "$json_file")"))
  ext_versions=()

  for ext in "${ext_names[@]}"; do
    versions=($(jq -r ".ext.${ext}[]" "$json_file"))
    for ver in "${versions[@]}"; do
      ext_versions+=("$ext,$ver")
    done
  done

  for php in "${php_versions[@]}"; do
    # for platform in "${platforms[@]}"; do
      for os in "${oses[@]}"; do
        for ext_ver in "${ext_versions[@]}"; do
          ext=$(echo "$ext_ver" | cut -d, -f1)
          ver=$(echo "$ext_ver" | cut -d, -f2)
          if [ -f "history/$php/$ext/$ver/$os.json" ]; then
            continue
          fi

          printf '{"php":"%s","ext":"%s","ver":"%s","os":"%s"}\n' \
            "$php" \
            "$ext" \
            "$ver" \
            "$os" >>missed.jsonl
        done
      done
    # done
  done
}

main
