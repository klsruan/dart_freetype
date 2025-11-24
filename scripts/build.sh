#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FT_SRC="$ROOT/src/freetype"

UNAME="$(uname -s)"
if [[ "$UNAME" == "Linux" ]]; then
    PLATFORM="linux"
    LIB_EXT="so"
    FLUTTER_OUT="$ROOT/$PLATFORM/lib"
elif [[ "$UNAME" == "Darwin" ]]; then
    PLATFORM="macos"
    LIB_EXT="dylib"
    FLUTTER_OUT="$ROOT/$PLATFORM/lib"
elif [[ "$UNAME" =~ MINGW|MSYS|CYGWIN ]]; then
    PLATFORM="windows"
    LIB_EXT="dll"
    FLUTTER_OUT="$ROOT/$PLATFORM/bin"
else
    exit 1
fi

mkdir -p "$FLUTTER_OUT"

BUILD_DIR="$FT_SRC/build_$PLATFORM"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

meson setup --default-library=shared --buildtype=release "$BUILD_DIR" "$FT_SRC"
meson compile -C "$BUILD_DIR"

FOUND=$(find "$BUILD_DIR" -name "*.$LIB_EXT" -type f)
if [[ -z "$FOUND" ]]; then
    exit 1
fi

for f in $FOUND; do
    cp "$f" "$FLUTTER_OUT/"
done

echo "Build done!"