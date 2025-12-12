#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FT_SRC="$ROOT/src/freetype"
OUT_DIR="$ROOT/ios/lib"

ARCHS=("arm64" "x86_64")
PLATFORMS=("iPhoneOS" "iPhoneSimulator")

mkdir -p "$OUT_DIR"

for i in "${!ARCHS[@]}"; do
    ARCH="${ARCHS[$i]}"
    PLATFORM="${PLATFORMS[$i]}"

    BUILD_DIR="$ROOT/build/ios/$ARCH"
    INSTALL_DIR="$OUT_DIR/$ARCH"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_DIR"

    cmake "$FT_SRC" \
        -B "$BUILD_DIR" \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="$FT_SRC/ios.toolchain.cmake" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
        -DCMAKE_OSX_SYSROOT=$PLATFORM \
        -DBUILD_SHARED_LIBS=ON

    cmake --build "$BUILD_DIR" --config Release

    DYLIB_FILE="$(find "$BUILD_DIR" -name 'libfreetype*.dylib' | head -n 1)"

    if [[ ! -f "$DYLIB_FILE" ]]; then
        echo "libfreetype.dylib not found for $ARCH"
        exit 1
    fi

    cp "$DYLIB_FILE" "$INSTALL_DIR/"
done

UNIVERSAL_LIB="$OUT_DIR/libfreetype.dylib"
lipo -create \
    "$OUT_DIR/arm64/libfreetype.dylib" \
    "$OUT_DIR/x86_64/libfreetype.dylib" \
    -output "$UNIVERSAL_LIB"

echo "Build iOS done! Universal library: $UNIVERSAL_LIB"