#!/usr/bin/env bash
# Fetches the Moonshine models that the iOS app bundles.
#
# Moonshine ships one model per language rather than one multilingual model, so
# a language is a model.
#
# The base URLs below were read from the library's own download manifest
# (moonshine_get_stt_dependencies) rather than guessed, because the quantized
# build directory is versioned and changes when the models are re-released. To
# refresh them, build a tiny program against the macOS slice of
# Moonshine.xcframework and print the manifest:
#
#   #include "moonshine-c-api.h"
#   struct moonshine_option_t opts[1] = {{"model_arch", "2"}};
#   char *json = NULL;
#   moonshine_get_stt_dependencies("en", opts, 1, &json);
#   puts(json);
#
# The weights are not committed; run this before building for iOS.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODELS_DIR="${REPO_ROOT}/ios/Runner/moonshine_models"

# <directory name> <base url>
MODELS=(
  "tiny-streaming-ar https://download.moonshine.ai/model/tiny-streaming-ar/quantized_26_08_24"
  "tiny-streaming-en https://download.moonshine.ai/model/tiny-streaming-en/quantized_26_08_21"
)

FILES=(
  adapter.ort
  cross_kv.ort
  decoder_kv.ort
  encoder.ort
  frontend.model.ort
  frontend.weights.ort
  streaming_config.json
  tokenizer.bin
)

for entry in "${MODELS[@]}"; do
  read -r name base <<<"${entry}"
  dest="${MODELS_DIR}/${name}"

  if [[ -s "${dest}/streaming_config.json" ]]; then
    echo "have ${name}"
    continue
  fi

  echo "fetching ${name}"
  mkdir -p "${dest}"
  for file in "${FILES[@]}"; do
    curl -fsSL "${base}/${file}" -o "${dest}/${file}"
  done
done

echo "models ready in ${MODELS_DIR}"
