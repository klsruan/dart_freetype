import 'dart:typed_data';

import 'package:dart_freetype/dart_freetype.dart';
import 'package:flutter/services.dart';

/// Cross-platform example (native + Web/Wasm) using the high-level API.
///
/// This example loads a font from Flutter assets as bytes so it works on Web.
Future<void> main() async {
  final ft = await Freetype.create();

  // Replace with a real asset in your app.
  final ByteData bd = await rootBundle.load('assets/fonts/MyFont.ttf');
  final Uint8List bytes = bd.buffer.asUint8List();

  final face = ft.newFaceFromBytes(bytes);
  face.setPixelSizes(0, 32);

  final ok = face.loadChar('A'.codeUnitAt(0), LoadFlag.DEFAULT);
  if (!ok) {
    throw Exception('FT_Load_Char failed.');
  }

  final bmp = face.glyph.bitmap();
  print('bitmap: ${bmp.width}x${bmp.rows} pitch=${bmp.pitch} bytes=${bmp.buffer.length}');
}

