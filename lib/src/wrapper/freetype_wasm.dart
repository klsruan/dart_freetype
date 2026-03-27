import 'dart:async';
import 'dart:js_interop';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/services.dart';

@JS('globalThis.createFreetypeModule')
external JSPromise<JSObject> _createFreetypeModule([JSObject? moduleArg]);

@JS('globalThis.createFreetypeModule')
external JSAny? _existingCreateFreetypeModule;

extension type _ModuleArgs(JSObject _) implements JSObject {
  external set wasmBinary(JSUint8Array value);
}

extension type _FTModule(JSObject _) implements JSObject {
  external int _malloc(int bytes);
  external void _free(int ptr);

  external int _my_init();
  external int _my_new_face_from_memory(int dataPtr, int len);
  external int _my_new_face_from_memory_ex(int dataPtr, int len, int faceIndex);
  external int _my_set_char_size(
    int facePtr,
    int charWidth,
    int charHeight,
    int hres,
    int vres,
  );
  external int _my_set_pixel_size(int facePtr, int px);
  external int _my_set_pixel_sizes(int facePtr, int w, int h);
  external void _my_set_transform(
    int facePtr,
    int xx,
    int xy,
    int yx,
    int yy,
    int dx,
    int dy,
  );
  external int _my_get_char_index(int facePtr, int charcode);
  external int _my_load_char(int facePtr, int codepoint, int loadFlags);
  external int _my_load_glyph(int facePtr, int glyphIndex, int loadFlags);
  external int _my_render_glyph(int facePtr, int renderMode);
  external int _my_get_glyph_bitmap(
    int facePtr,
    int wPtr,
    int hPtr,
    int stridePtr,
    int leftPtr,
    int topPtr,
    int advXPtr,
    int advYPtr,
  );
  external int _my_get_face_metrics(
    int facePtr,
    int ascPtr,
    int descPtr,
    int heightPtr,
    int maxAdvWPtr,
    int maxAdvHPtr,
    int underlinePosPtr,
    int unitsPerEmPtr,
  );
  external int _my_render_char(
    int facePtr,
    int codepoint,
    int wPtr,
    int hPtr,
    int stridePtr,
  );
  external void _my_free_bitmap(int ptr);
  external void _my_free_face(int facePtr);
  external void _my_done();

  // Added in `native_libs/wasm/freetype.js` to make Dart/Wasm interop easier.
  external int __dartI32Get(int ptr);
  external void __dartU8Set(int ptr, JSUint8Array bytes);
  external JSUint8Array __dartU8Sub(int ptr, int len);
}

Future<JSObject> _loadModule() {
  return _moduleFuture ??= () async {
    await _ensureScriptLoaded();
    final wasm = await _loadWasmBytes().timeout(const Duration(seconds: 30));
    final args = _ModuleArgs(JSObject());
    args.wasmBinary = wasm.toJS;
    return _createFreetypeModule(args).toDart.timeout(const Duration(seconds: 30));
  }();
}

Future<JSObject>? _moduleFuture;

Future<void>? _scriptLoadFuture;

Future<void> _ensureScriptLoaded() async {
  if (_existingCreateFreetypeModule != null) return;
  if (_scriptLoadFuture != null) return _scriptLoadFuture!;

  _scriptLoadFuture = () async {
    // Load the JS wrapper from Flutter assets and inject it.
    final js = await _loadJsSource().timeout(const Duration(seconds: 30));

    if (js.contains('export default')) {
      await _injectEsModuleFromSource(js).timeout(const Duration(seconds: 30));
    } else {
      await _injectClassicScriptFromSource(js).timeout(const Duration(seconds: 30));
      _assignFactoryToGlobalThis();
    }

    if (_existingCreateFreetypeModule == null) {
      throw StateError('createFreetypeModule was not registered after injection.');
    }
  }();

  return _scriptLoadFuture!;
}

Future<String> _loadJsSource() async {
  try {
    return await rootBundle.loadString(
      'packages/dart_freetype/native_libs/wasm/freetype.js',
    );
  } catch (_) {
    return await rootBundle.loadString('native_libs/wasm/freetype.js');
  }
}

Future<Uint8List> _loadWasmBytes() async {
  try {
    final bd = await rootBundle.load(
      'packages/dart_freetype/native_libs/wasm/freetype.wasm',
    );
    return bd.buffer.asUint8List();
  } catch (_) {
    final bd = await rootBundle.load('native_libs/wasm/freetype.wasm');
    return bd.buffer.asUint8List();
  }
}

Future<void> _injectClassicScriptFromSource(String js) async {
  final head = html.document.head;
  if (head == null) {
    throw StateError('document.head not found.');
  }

  final blob = html.Blob(<Object>[js], 'text/javascript');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..type = 'text/javascript'
    ..src = url
    ..async = true;

  late final StreamSubscription<html.Event> loadSub;
  late final StreamSubscription<html.Event> errSub;

  void cleanup() {
    loadSub.cancel();
    errSub.cancel();
    script.remove();
    html.Url.revokeObjectUrl(url);
  }

  loadSub = script.onLoad.listen((_) {
    cleanup();
    completer.complete();
  });
  errSub = script.onError.listen((_) {
    cleanup();
    completer.completeError(StateError('Failed to load JS from Blob URL.'));
  });

  head.append(script);
  await completer.future;
}

Future<void> _injectEsModuleFromSource(String js) async {
  final head = html.document.head;
  if (head == null) {
    throw StateError('document.head not found.');
  }

  final moduleBlob = html.Blob(<Object>[js], 'text/javascript');
  final moduleUrl = html.Url.createObjectUrlFromBlob(moduleBlob);

  final wrapper = "import FreeTypeInit from '$moduleUrl';"
      "globalThis.createFreetypeModule = FreeTypeInit;";
  final wrapperBlob = html.Blob(<Object>[wrapper], 'text/javascript');
  final wrapperUrl = html.Url.createObjectUrlFromBlob(wrapperBlob);

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..type = 'module'
    ..src = wrapperUrl
    ..async = true;

  late final StreamSubscription<html.Event> loadSub;
  late final StreamSubscription<html.Event> errSub;

  void cleanup() {
    loadSub.cancel();
    errSub.cancel();
    script.remove();
    html.Url.revokeObjectUrl(wrapperUrl);
    html.Url.revokeObjectUrl(moduleUrl);
  }

  loadSub = script.onLoad.listen((_) {
    cleanup();
    if (!completer.isCompleted) completer.complete();
  });
  errSub = script.onError.listen((_) {
    cleanup();
    if (!completer.isCompleted) {
      completer.completeError(StateError('Failed to inject freetype.js (module).'));
    }
  });

  head.append(script);
  await completer.future;
}

void _assignFactoryToGlobalThis() {
  final head = html.document.head;
  if (head == null) return;
  final script = html.ScriptElement()
    ..type = 'text/javascript'
    ..text = '(function(){'
        'if (!globalThis.createFreetypeModule && typeof createFreetypeModule === \"function\") {'
        'globalThis.createFreetypeModule = createFreetypeModule;'
        '}'
        '})();';
  head.append(script);
  script.remove();
}

class LoadFlag {
  final int value;
  const LoadFlag(this.value);

  static const DEFAULT = LoadFlag(0);
  static const NO_SCALE = LoadFlag(1 << 0);
  static const NO_HINTING = LoadFlag(1 << 1);
  static const RENDER = LoadFlag(1 << 2);
  static const NO_BITMAP = LoadFlag(1 << 3);
  static const FORCE_AUTOHINT = LoadFlag(1 << 5);
  static const MONOCHROME = LoadFlag(1 << 12);
  static const TARGET_NORMAL = LoadFlag(0x00000);
  static const COLOR = LoadFlag(1 << 20);
}

class RenderMode {
  final int value;
  const RenderMode(this.value);

  static const normal = RenderMode(0);
  static const light = RenderMode(1);
  static const mono = RenderMode(2);
  static const lcd = RenderMode(3);
  static const lcdV = RenderMode(4);
  static const sdf = RenderMode(5);
}

class Vector {
  final int x;
  final int y;
  const Vector(this.x, this.y);
}

class Matrix {
  final int xx;
  final int xy;
  final int yx;
  final int yy;
  const Matrix(this.xx, this.xy, this.yx, this.yy);
}

class Freetype {
  final _FTModule _m;
  bool _isFree = false;

  static final Finalizer<Freetype> _finalizer =
      Finalizer((instance) => instance.free());

  Freetype._(this._m) {
    _finalizer.attach(this, this);
  }

  static Future<Freetype> create() async {
    final mod = _FTModule(await _loadModule());
    final err = mod._my_init();
    if (err != 0) {
      throw Exception('FT_Init_FreeType failed: $err');
    }
    return Freetype._(mod);
  }

  Face newFaceFromBytes(Uint8List bytes, {int faceIndex = 0}) {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes.length, 'bytes', 'Font data is empty.');
    }

    final dataPtr = _m._malloc(bytes.length);
    _m.__dartU8Set(dataPtr, bytes.toJS);

    final facePtr = _m._my_new_face_from_memory_ex(dataPtr, bytes.length, faceIndex);
    if (facePtr == 0) {
      _m._free(dataPtr);
      throw Exception('FT_New_Memory_Face failed.');
    }

    return Face._wasm(_m, facePtr, dataPtr);
  }

  void free() {
    if (_isFree) return;
    _isFree = true;
    _finalizer.detach(this);
    _m._my_done();
  }
}

class Face {
  final _FTModule _m;
  final int _facePtr;
  final int _dataPtr;
  bool _isFree = false;

  late final GlyphSlot glyph;
  _FaceMetrics? _metrics;

  Face._wasm(this._m, this._facePtr, this._dataPtr) {
    glyph = GlyphSlot._wasm(this);
  }

  void setCharSize(
    int charWidth,
    int charHeight,
    int horzResolution,
    int vertResolution,
  ) {
    final err = _m._my_set_char_size(
      _facePtr,
      charWidth,
      charHeight,
      horzResolution,
      vertResolution,
    );
    if (err != 0) {
      throw Exception('FT_Set_Char_Size failed: $err');
    }
  }

  void setPixelSizes(int pixelWidth, int pixelHeight) {
    final err = _m._my_set_pixel_sizes(_facePtr, pixelWidth, pixelHeight);
    if (err != 0) {
      throw Exception('FT_Set_Pixel_Sizes failed: $err');
    }
  }

  void setTransform(Matrix matrix, Vector delta) {
    _m._my_set_transform(
      _facePtr,
      matrix.xx,
      matrix.xy,
      matrix.yx,
      matrix.yy,
      delta.x,
      delta.y,
    );
  }

  bool loadChar(int charCode, LoadFlag flags) {
    final err = _m._my_load_char(_facePtr, charCode, flags.value);
    if (err != 0) return false;
    if ((flags.value & LoadFlag.RENDER.value) != 0) {
      glyph.renderGlyph(RenderMode.normal);
    }
    return true;
  }

  void loadGlyph(int glyphIndex, LoadFlag flags) {
    final err = _m._my_load_glyph(_facePtr, glyphIndex, flags.value);
    if (err != 0) {
      throw Exception('FT_Load_Glyph failed: $err');
    }
    if ((flags.value & LoadFlag.RENDER.value) != 0) {
      glyph.renderGlyph(RenderMode.normal);
    }
  }

  int getCharIndex(int charcode) {
    final res = _m._my_get_char_index(_facePtr, charcode);
    if (res == 0) {
      throw Exception('Undefined character code');
    }
    return res;
  }

  _FaceMetrics _loadMetrics() {
    final cached = _metrics;
    if (cached != null) return cached;

    final ascPtr = _m._malloc(4);
    final descPtr = _m._malloc(4);
    final heightPtr = _m._malloc(4);
    final maxAdvWPtr = _m._malloc(4);
    final maxAdvHPtr = _m._malloc(4);
    final underlinePosPtr = _m._malloc(4);
    final unitsPerEmPtr = _m._malloc(4);
    try {
      final err = _m._my_get_face_metrics(
        _facePtr,
        ascPtr,
        descPtr,
        heightPtr,
        maxAdvWPtr,
        maxAdvHPtr,
        underlinePosPtr,
        unitsPerEmPtr,
      );
      if (err != 0) {
        throw Exception('Failed to read face metrics.');
      }
      final metrics = _FaceMetrics(
        ascender: _m.__dartI32Get(ascPtr),
        descender: _m.__dartI32Get(descPtr),
        height: _m.__dartI32Get(heightPtr),
        maxAdvanceWidth: _m.__dartI32Get(maxAdvWPtr),
        maxAdvanceHeight: _m.__dartI32Get(maxAdvHPtr),
        underlinePosition: _m.__dartI32Get(underlinePosPtr),
        unitsPerEm: _m.__dartI32Get(unitsPerEmPtr),
      );
      _metrics = metrics;
      return metrics;
    } finally {
      _m._free(ascPtr);
      _m._free(descPtr);
      _m._free(heightPtr);
      _m._free(maxAdvWPtr);
      _m._free(maxAdvHPtr);
      _m._free(underlinePosPtr);
      _m._free(unitsPerEmPtr);
    }
  }

  int get ascender => _loadMetrics().ascender;
  int get descender => _loadMetrics().descender;
  int get emSize => _loadMetrics().unitsPerEm;
  int get height => _loadMetrics().height;
  int get maxAdvanceWidth => _loadMetrics().maxAdvanceWidth;
  int get maxAdvanceHeight => _loadMetrics().maxAdvanceHeight;
  int get underlinePosition => _loadMetrics().underlinePosition;

  void free() {
    if (_isFree) return;
    _isFree = true;
    _m._my_free_face(_facePtr);
    _m._free(_dataPtr);
  }
}

class GlyphSlot {
  final Face _face;

  Bitmap? _bitmap;
  int _bitmapLeft = 0;
  int _bitmapTop = 0;
  Vector _advance = const Vector(0, 0);

  GlyphSlot._wasm(this._face);

  Vector get advance => _advance;
  int get bitmapLeft => _bitmapLeft;
  int get bitmapTop => _bitmapTop;

  void renderGlyph(RenderMode mode) {
    final err = _face._m._my_render_glyph(_face._facePtr, mode.value);
    if (err != 0) {
      throw Exception('FT_Render_Glyph failed: $err');
    }
    _bitmap = _readBitmap();
  }

  Bitmap bitmap() {
    final bmp = _bitmap;
    if (bmp == null) {
      throw StateError(
        'No glyph bitmap available. Call loadChar(..., LoadFlag.RENDER) '
        'or call renderGlyph(...) after loadChar/loadGlyph.',
      );
    }
    return bmp;
  }

  Bitmap _readBitmap() {
    final wPtr = _face._m._malloc(4);
    final hPtr = _face._m._malloc(4);
    final stridePtr = _face._m._malloc(4);
    final leftPtr = _face._m._malloc(4);
    final topPtr = _face._m._malloc(4);
    final advXPtr = _face._m._malloc(4);
    final advYPtr = _face._m._malloc(4);

    try {
      final bmpPtr = _face._m._my_get_glyph_bitmap(
        _face._facePtr,
        wPtr,
        hPtr,
        stridePtr,
        leftPtr,
        topPtr,
        advXPtr,
        advYPtr,
      );
      if (bmpPtr == 0) {
        return Bitmap._wasm(Uint8List(0), 0, 0, 0);
      }

      final width = _face._m.__dartI32Get(wPtr);
      final rows = _face._m.__dartI32Get(hPtr);
      final pitch = _face._m.__dartI32Get(stridePtr);
      _bitmapLeft = _face._m.__dartI32Get(leftPtr);
      _bitmapTop = _face._m.__dartI32Get(topPtr);
      _advance = Vector(_face._m.__dartI32Get(advXPtr), _face._m.__dartI32Get(advYPtr));

      final size = rows * pitch;
      final data = _face._m.__dartU8Sub(bmpPtr, size).toDart;
      _face._m._my_free_bitmap(bmpPtr);

      return Bitmap._wasm(Uint8List.fromList(data), width, rows, pitch);
    } finally {
      _face._m._free(wPtr);
      _face._m._free(hPtr);
      _face._m._free(stridePtr);
      _face._m._free(leftPtr);
      _face._m._free(topPtr);
      _face._m._free(advXPtr);
      _face._m._free(advYPtr);
    }
  }
}

class Bitmap {
  final Uint8List _bytes;
  final int _width;
  final int _rows;
  final int _pitch;

  Bitmap._wasm(this._bytes, this._width, this._rows, this._pitch);

  List<int> get buffer => _bytes;
  int get width => _width;
  int get rows => _rows;
  int get pitch => _pitch;
}

class _FaceMetrics {
  final int ascender;
  final int descender;
  final int height;
  final int maxAdvanceWidth;
  final int maxAdvanceHeight;
  final int underlinePosition;
  final int unitsPerEm;

  const _FaceMetrics({
    required this.ascender,
    required this.descender,
    required this.height,
    required this.maxAdvanceWidth,
    required this.maxAdvanceHeight,
    required this.underlinePosition,
    required this.unitsPerEm,
  });
}
