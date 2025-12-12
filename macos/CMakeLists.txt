cmake_minimum_required(VERSION 3.10)
project(dart_freetype_macos LANGUAGES C)

set(FREETYPE_DYLIB_SRC "${CMAKE_CURRENT_SOURCE_DIR}/libfreetype.6.dylib")
set(FLUTTER_PLUGIN_MACOS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../macos")

file(MAKE_DIRECTORY "${FLUTTER_PLUGIN_MACOS_DIR}")

add_custom_command(
    OUTPUT "${FLUTTER_PLUGIN_MACOS_DIR}/libfreetype.6.dylib"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${FREETYPE_DYLIB_SRC}"
        "${FLUTTER_PLUGIN_MACOS_DIR}/libfreetype.6.dylib"
    VERBATIM
)

add_custom_target(copy_freetype_macos ALL
    DEPENDS "${FLUTTER_PLUGIN_MACOS_DIR}/libfreetype.6.dylib"
)
