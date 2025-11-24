set(FREETYPE_DLLS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib")
set(FLUTTER_DEBUG_DIR   "${CMAKE_BINARY_DIR}/../runner/Debug")
set(FLUTTER_RELEASE_DIR "${CMAKE_BINARY_DIR}/../runner/Release")

add_custom_command(
    OUTPUT
        "${CMAKE_BINARY_DIR}/Debug/.dlls_copied_stamp"
        "${CMAKE_BINARY_DIR}/Release/.dlls_copied_stamp"
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "${FLUTTER_DEBUG_DIR}"
        "${FLUTTER_RELEASE_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FREETYPE_DLLS_SOURCE_DIR}" "${FLUTTER_DEBUG_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FREETYPE_DLLS_SOURCE_DIR}" "${FLUTTER_RELEASE_DIR}"
    COMMAND ${CMAKE_COMMAND} -E touch
        "${CMAKE_BINARY_DIR}/Debug/.dlls_copied_stamp"
    COMMAND ${CMAKE_COMMAND} -E touch
        "${CMAKE_BINARY_DIR}/Release/.dlls_copied_stamp"
    VERBATIM
)

add_custom_target(copy_freetype_dependencies ALL DEPENDS
    "${CMAKE_BINARY_DIR}/Debug/.dlls_copied_stamp"
    "${CMAKE_BINARY_DIR}/Release/.dlls_copied_stamp"
)