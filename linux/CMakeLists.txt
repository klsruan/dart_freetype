# dart_freetype/src/linux/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(dart_freetype_linux LANGUAGES CXX)

set(NATIVE_LIBS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../lib")
set(PLUGIN_BUNDLE_DEBUG_DIR   "${CMAKE_BINARY_DIR}/../../../debug/lib")
set(PLUGIN_BUNDLE_RELEASE_DIR "${CMAKE_BINARY_DIR}/../../../release/bundle/lib")

add_custom_command(
    OUTPUT
        "${CMAKE_BINARY_DIR}/freetype_copied_debug"
        "${CMAKE_BINARY_DIR}/freetype_copied_release"
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "${PLUGIN_BUNDLE_DEBUG_DIR}"
        "${PLUGIN_BUNDLE_RELEASE_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${NATIVE_LIBS_SOURCE_DIR}"
        "${PLUGIN_BUNDLE_DEBUG_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${NATIVE_LIBS_SOURCE_DIR}"
        "${PLUGIN_BUNDLE_RELEASE_DIR}"
    COMMAND ${CMAKE_COMMAND} -E touch
        "${CMAKE_BINARY_DIR}/freetype_copied_debug"
        "${CMAKE_BINARY_DIR}/freetype_copied_release"
    VERBATIM
)

add_custom_target(copy_freetype ALL DEPENDS
    "${CMAKE_BINARY_DIR}/freetype_copied_debug"
    "${CMAKE_BINARY_DIR}/freetype_copied_release"
)