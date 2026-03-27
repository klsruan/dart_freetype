import 'dart:ffi';

import 'package:dart_freetype/dart_freetype_ffi.dart';
import 'package:ffi/ffi.dart';

/// Low-level example using the generated `ffigen` bindings.
///
/// Not supported on Web/Wasm.
void main() {
  // If you want to force a specific library path (useful for debugging):
  // final dylib = loadDynamicLibrary(path: '/absolute/path/to/libdart_freetype.so');
  final dylib = loadDynamicLibrary();
  final ft = FreetypeBinding(dylib);

  final library = calloc<FT_Library>();
  final err = ft.FT_Init_FreeType(library);
  if (err != FT_Err_Ok) {
    throw Exception('FT_Init_FreeType failed: $err');
  }

  ft.FT_Done_FreeType(library.value);
  calloc.free(library);

  print('FreeType initialized successfully.');
}

