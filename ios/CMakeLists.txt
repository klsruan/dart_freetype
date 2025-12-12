cmake_minimum_required(VERSION 3.10)
project(dart_freetype_ios LANGUAGES C)

set(FREETYPE_A_SRC "${CMAKE_CURRENT_SOURCE_DIR}/libfreetype.a")
set(FLUTTER_PLUGIN_IOS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../ios")

file(MAKE_DIRECTORY "${FLUTTER_PLUGIN_IOS_DIR}")

add_custom_command(
    OUTPUT "${FLUTTER_PLUGIN_IOS_DIR}/libfreetype.a"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${FREETYPE_A_SRC}"
        "${FLUTTER_PLUGIN_IOS_DIR}/libfreetype.a"
    VERBATIM
)

add_custom_target(copy_freetype_ios ALL
    DEPENDS "${FLUTTER_PLUGIN_IOS_DIR}/libfreetype.a"
)