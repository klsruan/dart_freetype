import 'dart:js_interop';

@JS('loadFreeType')
external JSPromise<JSObject> loadFreeTypeModule();

@JS('Module')
external set emscriptenModule(JSObject m);

extension type JSPointer(JSObject _) implements JSObject {
  factory JSPointer.empty() => JSPointer(JSObject());
}

@JS('FT_Init_FreeType')
external int FT_Init_FreeType(JSPointer library);

@JS('FT_New_Face')
external int FT_New_Face(JSPointer library, JSString path, int faceIndex, JSPointer face);

@JS('FT_Set_Pixel_Sizes')
external int FT_Set_Pixel_Sizes(JSPointer face, int width, int height);

@JS('FT_Load_Char')
external int FT_Load_Char(JSPointer face, int charCode, int loadFlags);

@JS('FT_Render_Glyph')
external int FT_Render_Glyph(JSPointer glyphSlot, int renderMode);

@JS('FT_Done_Face')
external int FT_Done_Face(JSPointer face);

@JS('FT_Done_FreeType')
external int FT_Done_FreeType(JSPointer library);

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

  static const Normal = RenderMode(0);
  static const Light = RenderMode(1);
  static const Mono = RenderMode(2);
  static const Lcd = RenderMode(3);
  static const LcdV = RenderMode(4);
  static const Sdf = RenderMode(5);
}

class FreetypeWasm {
  final JSPointer library;
  final JSObject module;

  FreetypeWasm._(this.module, this.library);

  static Future<FreetypeWasm> create() async {
    final mod = await loadFreeTypeModule().toDart;
    emscriptenModule = mod;

    final lib = JSPointer.empty();
    final err = FT_Init_FreeType(lib);
    if (err != 0) throw Exception('FT_Init_FreeType failed: $err');
    return FreetypeWasm._(mod, lib);
  }

  Face newFace(String path, {int faceIndex = 0}) {
    final facePtr = JSPointer.empty();
    final err = FT_New_Face(library, path.toJS, faceIndex, facePtr);
    if (err != 0) throw Exception('FT_New_Face failed: $err');
    return Face._wasm(this, facePtr);
  }

  void free() => FT_Done_FreeType(library);
}

class Face {
  final FreetypeWasm ft;
  final JSPointer face;

  Face._wasm(this.ft, this.face);

  void setPixelSizes(int width, int height) {
    final err = FT_Set_Pixel_Sizes(face, width, height);
    if (err != 0) throw Exception('FT_Set_Pixel_Sizes failed: $err');
  }

  bool loadChar(int charCode, LoadFlag flags) {
    final err = FT_Load_Char(face, charCode, flags.value);
    return err == 0;
  }

  GlyphSlot get glyph => GlyphSlot._wasm(face);

  void free() => FT_Done_Face(face);
}

class GlyphSlot {
  final JSPointer slot;

  GlyphSlot._wasm(this.slot);

  void renderGlyph(RenderMode mode) {
    final err = FT_Render_Glyph(slot, mode.value);
    if (err != 0) throw Exception('FT_Render_Glyph failed: $err');
  }

  Bitmap bitmap() => Bitmap._wasm(slot);
}

class Bitmap {
  final JSPointer slot;

  Bitmap._wasm(this.slot);

  List<int> get buffer => <int>[];
  int get width => 0;
  int get rows => 0;
  int get pitch => 0;
}
