#include <stdint.h>

// This file exists so each platform build has at least one translation unit
// owned by this plugin. The actual FreeType API symbols are provided by the
// vendored FreeType sources under `src/freetype/`.
//
// We also compile `src/freetype_wrapper.c` to expose a small stable ABI that is
// used by the Web/Wasm implementation.
uint32_t dart_freetype_dummy(void) { return 0; }

