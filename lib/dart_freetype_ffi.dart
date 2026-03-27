/// Native (Dart VM / Flutter native) FFI exports.
///
/// This library is **not** supported on Web/Wasm because it exports `dart:ffi`
/// bindings. For cross-platform usage, import `package:dart_freetype/dart_freetype.dart`
/// and use the high-level API (`Freetype.create()`).
library dart_freetype_ffi;

export 'src/generated_bindings.dart';
export 'src/errors.dart';
export 'src/extensions/extensions.dart';
export 'src/load.dart';
export 'src/wrapper/freetype_native.dart';
