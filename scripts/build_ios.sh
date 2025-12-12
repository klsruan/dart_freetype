#!/bin/bash
set -e

BUILD_DIR=$(pwd)/build_ios
mkdir -p $BUILD_DIR

TOOLCHAIN_FILE=/tmp/ios-cmake/ios.toolchain.cmake

cmake -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE \
      -DPLATFORM=OS64 \
      -DCMAKE_BUILD_TYPE=Release \
      -B $BUILD_DIR \
      -S src/freetype

cmake --build $BUILD_DIR