cmake_minimum_required(VERSION 3.10)
project(dart_freetype_linux VERSION 1.0.0 LANGUAGES CXX)

set(FREETYPE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../lib")

set(FLUTTER_PLUGIN_LIB_DIR_DEBUG   "${CMAKE_BINARY_DIR}/../../debug/lib")
set(FLUTTER_PLUGIN_LIB_DIR_RELEASE "${CMAKE_BINARY_DIR}/../../release/bundle/lib")

add_custom_command(
    OUTPUT
        "${CMAKE_BINARY_DIR}/freetype_copied_debug"
        "${CMAKE_BINARY_DIR}/freetype_copied_release"
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "${FLUTTER_PLUGIN_LIB_DIR_DEBUG}"
        "${FLUTTER_PLUGIN_LIB_DIR_RELEASE}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FREETYPE_SOURCE_DIR}"
        "${FLUTTER_PLUGIN_LIB_DIR_DEBUG}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FREETYPE_SOURCE_DIR}"
        "${FLUTTER_PLUGIN_LIB_DIR_RELEASE}"
    COMMAND ${CMAKE_COMMAND} -E touch
        "${CMAKE_BINARY_DIR}/freetype_copied_debug"
        "${CMAKE_BINARY_DIR}/freetype_copied_release"
    VERBATIM
)

add_custom_target(copy_freetype ALL
    DEPENDS
        "${CMAKE_BINARY_DIR}/freetype_copied_debug"
        "${CMAKE_BINARY_DIR}/freetype_copied_release"
)