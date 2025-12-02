#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FT_SRC="$ROOT/src/freetype"
OUT_DIR="$ROOT/native_libs/wasm"

EMSDK_ROOT="/home/zeref/github/emsdk"
UPSTREAM_EMS_PATH="$EMSDK_ROOT/upstream/emscripten"

EMCC="$UPSTREAM_EMS_PATH/emcc"
EMMAKE="$UPSTREAM_EMS_PATH/emmake"
EMCMAKE="$UPSTREAM_EMS_PATH/emcmake"
EMCONFIGURE="$UPSTREAM_EMS_PATH/emconfigure"

mkdir -p "$OUT_DIR/build"
mkdir -p "$OUT_DIR"

WRAPPER_C="$ROOT/src/freetype_wrapper.c"
if [[ ! -f "$WRAPPER_C" ]]; then
  echo "Wrapper C não encontrado em $WRAPPER_C"
  exit 1
fi

rm -rf "$OUT_DIR/build"/*
cd "$OUT_DIR/build"

if [[ ! -x "$EMCC" || ! -x "$EMMAKE" || ! -x "$EMCMAKE" ]]; then
  echo "Um ou mais binários do Emscripten não foram encontrados ou não são executáveis."
  exit 1
fi

"$EMCMAKE" cmake "$FT_SRC" \
  -DWITH_ZLIB=OFF \
  -DWITH_BZIP2=OFF \
  -DWITH_PNG=OFF \
  -DCMAKE_BUILD_TYPE=Release

echo "=== Compilando libfreetype.a ==="
"$EMMAKE" make -j"$(nproc)"

LIB_FILE="$(find . -name 'libfreetype.a' | head -n 1)"
if [[ ! -f "$LIB_FILE" ]]; then
  echo "libfreetype.a não encontrada!"
  exit 1
fi

"$EMCC" "$WRAPPER_C" -I"$FT_SRC/include" -L"$OUT_DIR/build" -lfreetype \
  -O3 \
  -s MODULARIZE=1 \
  -s EXPORT_NAME="createFreetypeModule" \
  -s EXPORTED_FUNCTIONS='["_my_init","_my_done","_my_new_face_from_memory","_my_set_pixel_size","_my_render_char","_my_free_bitmap","_my_free_face","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["cwrap","ccall"]' \
  -o "$OUT_DIR/freetype.js"

if [[ -f "$OUT_DIR/freetype.wasm" ]]; then
  echo "Build WebAssembly done!"
else
  exit 1
fi