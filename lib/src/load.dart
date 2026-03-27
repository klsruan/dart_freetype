import 'dart:ffi';
import 'dart:io';
import 'generated_bindings.dart';

DynamicLibrary loadDynamicLibrary({String? path}) {
  if (path != null && path.isNotEmpty) {
    return DynamicLibrary.open(path);
  }

  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }

  // Prefer the plugin-bundled FFI library produced by the `plugin_ffi`
  // build system (so the app doesn't need system-wide FreeType binaries).
  final candidates = <String>[
    if (Platform.isWindows) 'dart_freetype.dll',
    if (Platform.isMacOS) 'libdart_freetype.dylib',
    if (Platform.isLinux || Platform.isAndroid) 'libdart_freetype.so',

    // Backwards-compatible fallbacks (system or legacy names).
    if (Platform.isWindows) 'freetype.dll',
    if (Platform.isWindows) 'libfreetype-6.dll',
    if (Platform.isMacOS) 'libfreetype.dylib',
    if (Platform.isMacOS) 'libfreetype.6.dylib',
    if (Platform.isLinux) 'libfreetype.so',
    if (Platform.isLinux) 'libfreetype.so.6',
    if (Platform.isAndroid) 'libfreetype.so',
  ];

  for (final name in candidates) {
    try {
      return DynamicLibrary.open(name);
    } catch (_) {
      // try next
    }
  }

  throw Exception('[Error] Could not load FreeType dynamic library.');
}

FreetypeBinding loadFreeType() {
  return FreetypeBinding(loadDynamicLibrary());
}
