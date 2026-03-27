cmake_minimum_required(VERSION 3.12)
project(dart_freetype_library LANGUAGES C)

set(FREETYPE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../src/freetype")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(FT_DISABLE_ZLIB ON CACHE BOOL "" FORCE)
set(FT_DISABLE_BZIP2 ON CACHE BOOL "" FORCE)
set(FT_DISABLE_PNG ON CACHE BOOL "" FORCE)
set(FT_DISABLE_HARFBUZZ ON CACHE BOOL "" FORCE)
set(FT_DISABLE_BROTLI ON CACHE BOOL "" FORCE)

add_subdirectory("${FREETYPE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/freetype")
set_target_properties(freetype PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(dart_freetype SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../src/dart_freetype.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../src/freetype_wrapper.c"
)

target_include_directories(dart_freetype PRIVATE
  "${FREETYPE_DIR}/include"
)

target_link_libraries(dart_freetype
  "-Wl,--whole-archive"
  freetype
  "-Wl,--no-whole-archive"
  log
)

