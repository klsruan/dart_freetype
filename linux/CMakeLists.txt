# linux/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(dart_freetype_linux LANGUAGES C)

set(FREETYPE_SO_SRC "${CMAKE_CURRENT_SOURCE_DIR}/lib/libfreetype.so")
set(FLUTTER_BUNDLE_DEBUG   "${CMAKE_BINARY_DIR}/../../debug/bundle/lib/x86_64")
set(FLUTTER_BUNDLE_RELEASE "${CMAKE_BINARY_DIR}/../../release/bundle/lib/x86_64")

file(MAKE_DIRECTORY "${FLUTTER_BUNDLE_DEBUG}")
file(MAKE_DIRECTORY "${FLUTTER_BUNDLE_RELEASE}")

add_custom_command(
    OUTPUT
        "${FLUTTER_BUNDLE_DEBUG}/libfreetype.so"
        "${FLUTTER_BUNDLE_RELEASE}/libfreetype.so"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${FREETYPE_SO_SRC}"
        "${FLUTTER_BUNDLE_DEBUG}/libfreetype.so"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${FREETYPE_SO_SRC}"
        "${FLUTTER_BUNDLE_RELEASE}/libfreetype.so"
    VERBATIM
)

add_custom_target(copy_freetype_linux ALL
    DEPENDS
        "${FLUTTER_BUNDLE_DEBUG}/libfreetype.so"
        "${FLUTTER_BUNDLE_RELEASE}/libfreetype.so"
)