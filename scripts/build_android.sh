#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FT_SRC="$ROOT/src/freetype"
OUT_DIR="$ROOT/native_libs/android"
JNI_DIR="$ROOT/android/src/main/jniLibs"

NDK="$ANDROID_NDK_HOME"
API=21

if [[ -z "$NDK" ]]; then
  echo "ANDROID_NDK_HOME not defined"
  exit 1
fi

ABIS=("armeabi-v7a" "arm64-v8a" "x86_64")
for ABI in "${ABIS[@]}"; do
    BUILD_DIR="$ROOT/build/android/$ABI"
    INSTALL_DIR="$OUT_DIR/$ABI"
    JNI_OUT="$JNI_DIR/$ABI"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$JNI_OUT"

    cmake "$FT_SRC" \
        -B "$BUILD_DIR" \
        -G Ninja \
        -DANDROID_PLATFORM=android-$API \
        -DANDROID_ABI="$ABI" \
        -DANDROID_NDK="$NDK" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON

    cmake --build "$BUILD_DIR" --config Release

    SO_FILE="$(find "$BUILD_DIR" -name 'libfreetype.so' | head -n 1)"

    if [[ ! -f "$SO_FILE" ]]; then
        echo "libfreetype.so not found for $ABI"
        exit 1
    fi

    cp "$SO_FILE" "$INSTALL_DIR/"
    cp "$SO_FILE" "$JNI_OUT/"
done

echo "Build android done!"
