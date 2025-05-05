#!/bin/bash

set -euo pipefail

function main() {
  printf '' >missed.jsonl

  json_file=versions.json

  php_versions=($(jq -r '.php[]' "$json_file"))
  platforms=($(jq -r '.platform[]' "$json_file"))
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
    for platform in "${platforms[@]}"; do
      for os in "${oses[@]}"; do
        # 对于所有扩展及其版本组合
        for ext_ver in "${ext_versions[@]}"; do
          ext=$(echo "$ext_ver" | cut -d, -f1)
          ver=$(echo "$ext_ver" | cut -d, -f2)
          # 生成 JSON 输出
          if [ -f "history/$php/$ext/$ver/$platform/$os.json" ]; then
            continue
          fi

          if [ "$platform" = "linux/arm64" ]; then
            runson=ubuntu-24.04-arm
          elif [ "$platform" = "linux/amd64" ]; then
            runson="ubuntu-24.04"
          fi
          printf '{"php":"%s","ext":"%s","ver":"%s","os":"%s","platform":"%s","runson":"%s"}\n' \
            "$php" \
            "$ext" \
            "$ver" \
            "$os" \
            "$platform" \
            "$runson" >>missed.jsonl
        done
      done
    done
  done
  # jq -r 'keys[]' versions.json | while read -r phpVer; do
  #   jq -r ".\"$phpVer\" | keys[]" versions.json | while read -r extName; do
  #     echo "Processing PHP$phpVer - $extName"
  #     jq -r ".\"$phpVer\".\"$extName\" | keys[] | select(. != \"latest\")" versions.json | while read -r extVer; do
  #       jq -r ".\"$phpVer\".\"$extName\".\"$extVer\"[]"  versions.json | while read -r extOS; do
  #       echo  "$extOS aaaaa"
  #         # echo $extOS | jq -r ".platform[]" | while read -r aaa; do
  #         #   echo $aaa
  #         # done
  #       done
  #       # jq -r ".\"$phpVer\".\"$extName\".\"$extVer\"[]" versions.json | while read -r extOS; do
  #       #   if [ -f "history/$phpVer/$extName/$extVer/$extOS.json" ]; then
  #       #     continue
  #       #   fi
  #       #   printf '{"php":"%s","ext":"%s","ver":"%s","os":"%s"}\n' \
  #       #     "$phpVer" \
  #       #     "$extName" \
  #       #     "$extVer" \
  #       #     "$extOS" >> missed.jsonl
  #       # done
  #     done
  #   done
  # done
}

main
