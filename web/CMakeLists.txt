cmake_minimum_required(VERSION 3.10)
project(dart_freetype_web LANGUAGES NONE)

set(WASM_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../native_libs/wasm")
set(WASM_FILES
    "${WASM_SRC_DIR}/freetype.wasm"
    "${WASM_SRC_DIR}/freetype.js"
)

set(FLUTTER_WEB_ASSETS "${CMAKE_BINARY_DIR}/../../build/web/assets/native_libs/wasm")

file(MAKE_DIRECTORY "${FLUTTER_WEB_ASSETS}")

add_custom_command(
    OUTPUT "${FLUTTER_WEB_ASSETS}/freetype.wasm" "${FLUTTER_WEB_ASSETS}/freetype.js"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${WASM_SRC_DIR}/freetype.wasm"
        "${FLUTTER_WEB_ASSETS}/freetype.wasm"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${WASM_SRC_DIR}/freetype.js"
        "${FLUTTER_WEB_ASSETS}/freetype.js"
    DEPENDS ${WASM_FILES}
    VERBATIM
)

add_custom_target(copy_freetype_wasm ALL
    DEPENDS
        "${FLUTTER_WEB_ASSETS}/freetype.wasm"
        "${FLUTTER_WEB_ASSETS}/freetype.js"
)