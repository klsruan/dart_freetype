# dart_freetype

FreeType bindings for Flutter/Dart using FFI.

## Content
- Bindings generated automatically with ffigen
- Native FreeType is built automatically by the Flutter `plugin_ffi` build (Android/iOS/macOS/Linux/Windows)
- Web/Wasm uses the bundled `native_libs/wasm/freetype.{js,wasm}`

## Binding Generation

```
dart run ffigen
```

## Native builds (Android/iOS/macOS/Linux/Windows)

No manual steps required. The consuming Flutter app builds and bundles the native library automatically (Flutter `plugin_ffi`).

## Usage

Prefer the async constructor so the same code works on Web/Wasm and native:

```dart
final ft = await Freetype.create();
```

On Web/Wasm, load fonts from bytes (paths are not supported):

```dart
final face = ft.newFaceFromBytes(fontBytes);
```

If you need the raw `ffigen` bindings on native platforms, import:

```dart
import 'package:dart_freetype/dart_freetype_ffi.dart';
```

## Tests

- VM (default): `flutter test test/vm`
- Web/Wasm (optional): `RUN_WEB_TESTS=1 ./scripts/test_all.sh`
- All (VM only): `./scripts/test_all.sh`
