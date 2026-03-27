cmake_minimum_required(VERSION 3.15)
project(dart_freetype_library LANGUAGES C)

set(FREETYPE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src/freetype")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(FT_DISABLE_ZLIB ON CACHE BOOL "" FORCE)
set(FT_DISABLE_BZIP2 ON CACHE BOOL "" FORCE)
set(FT_DISABLE_PNG ON CACHE BOOL "" FORCE)
set(FT_DISABLE_HARFBUZZ ON CACHE BOOL "" FORCE)
set(FT_DISABLE_BROTLI ON CACHE BOOL "" FORCE)

add_subdirectory("${FREETYPE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/freetype")

add_library(dart_freetype SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/dart_freetype.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/freetype_wrapper.c"
)

target_include_directories(dart_freetype PRIVATE
  "${FREETYPE_DIR}/include"
)

target_link_libraries(dart_freetype PRIVATE freetype)

# Force all archive objects into the DLL so Dart can resolve the FreeType API.
if (MSVC)
  target_link_options(dart_freetype PRIVATE
    "/WHOLEARCHIVE:$<TARGET_LINKER_FILE:freetype>"
  )
endif()

set_target_properties(dart_freetype PROPERTIES
  OUTPUT_NAME "dart_freetype"
  WINDOWS_EXPORT_ALL_SYMBOLS ON
)

install(TARGETS dart_freetype
  RUNTIME DESTINATION "."
  LIBRARY DESTINATION "."
  ARCHIVE DESTINATION "."
)

