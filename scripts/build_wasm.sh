#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FT_SRC="$ROOT/src/freetype"
OUT_DIR="$ROOT/native_libs/wasm"

EMCC="${EMCC:-emcc}"
EMMAKE="${EMMAKE:-emmake}"
EMCMAKE="${EMCMAKE:-emcmake}"

mkdir -p "$OUT_DIR/build"
mkdir -p "$OUT_DIR"

WRAPPER_C="$ROOT/src/freetype_wrapper.c"
if [[ ! -f "$WRAPPER_C" ]]; then
  echo "Wrapper C not found at $WRAPPER_C"
  exit 1
fi

rm -rf "$OUT_DIR/build"/*
cd "$OUT_DIR/build"

if ! command -v "$EMCC" >/dev/null 2>&1 || ! command -v "$EMMAKE" >/dev/null 2>&1 || ! command -v "$EMCMAKE" >/dev/null 2>&1; then
  echo "Emscripten tools not found. Ensure emsdk is activated (emcc/emmake/emcmake in PATH)."
  exit 1
fi

"$EMCMAKE" cmake "$FT_SRC" \
  -DWITH_ZLIB=OFF \
  -DWITH_BZIP2=OFF \
  -DWITH_PNG=OFF \
  -DCMAKE_BUILD_TYPE=Release

echo "==> Building libfreetype.a"
"$EMMAKE" make -j"$(nproc)"

LIB_FILE="$(find . -name 'libfreetype.a' | head -n 1)"
if [[ ! -f "$LIB_FILE" ]]; then
  echo "libfreetype.a not found!"
  exit 1
fi

"$EMCC" "$WRAPPER_C" -I"$FT_SRC/include" -L"$OUT_DIR/build" -lfreetype \
  -O3 \
  -s MODULARIZE=1 \
  -s EXPORT_NAME="FreeTypeInit" \
  -s EXPORT_ES6=1 \
  -s EXPORTED_FUNCTIONS='["_my_init","_my_done","_my_new_face_from_memory","_my_new_face_from_memory_ex","_my_set_char_size","_my_set_pixel_sizes","_my_set_transform","_my_load_char","_my_load_glyph","_my_get_char_index","_my_render_glyph","_my_get_glyph_bitmap","_my_get_face_metrics","_my_free_bitmap","_my_free_face","_malloc","_free"]' \
  -s EXPORTED_RUNTIME_METHODS='["cwrap","ccall"]' \
  -o "$OUT_DIR/freetype.js"

echo "==> Patching freetype.js for Dart/Wasm interop helpers"
python3 - <<'PY'
import re
from pathlib import Path

# We are running from `$OUT_DIR/build`, so the output JS is one directory up.
p = Path("../freetype.js")
if not p.exists():
    raise SystemExit(f"freetype.js not found at {p.resolve()}")
s = p.read_text(encoding="utf-8")

# Expose heap views + wasmMemory on Module (and add helper functions) so Dart can
# move bytes in/out of linear memory without relying on emscripten internals.
pat = r"function updateMemoryViews\(\)\{var b=wasmMemory\.buffer;(?P<body>[^}]*)\}"
m = re.search(pat, s)
if not m:
    raise SystemExit("updateMemoryViews not found")

if "Module[\"__dartU8Sub\"]" not in s:
    assign = (
        "Module[\"wasmMemory\"]=wasmMemory;"
        "Module[\"HEAP8\"]=HEAP8;"
        "Module[\"HEAPU8\"]=HEAPU8;"
        "Module[\"HEAP16\"]=HEAP16;"
        "Module[\"HEAPU16\"]=HEAPU16;"
        "Module[\"HEAP32\"]=HEAP32;"
        "Module[\"HEAPU32\"]=HEAPU32;"
        "Module[\"HEAPF32\"]=HEAPF32;"
        "Module[\"HEAPF64\"]=HEAPF64;"
        "Module[\"__dartI32Get\"]=function(p){return HEAP32[p>>2];};"
        "Module[\"__dartU8Set\"]=function(p,a){HEAPU8.set(a,p);};"
        "Module[\"__dartU8Sub\"]=function(p,l){return HEAPU8.subarray(p,p+l);};"
    )

    def repl(match):
        b = match.group("body")
        if not b.endswith(";"):
            b = b + ";"
        return f"function updateMemoryViews(){{var b=wasmMemory.buffer;{b}{assign}}}"

    s = re.sub(pat, repl, s, count=1)
    p.write_text(s, encoding="utf-8")
    print("patched")
else:
    print("already patched")
PY

if [[ -f "$OUT_DIR/freetype.wasm" ]]; then
  echo "Build WebAssembly done!"
else
  exit 1
fi
