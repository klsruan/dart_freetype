@TestOn('browser')
import 'dart:typed_data';

import 'package:dart_freetype/dart_freetype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('web/wasm: module loads from package assets', () async {
    final ft = await Freetype.create();
    expect(ft, isNotNull);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('web/wasm: newFaceFromBytes throws on empty data', () async {
    final ft = await Freetype.create();
    expect(
      () => ft.newFaceFromBytes(Uint8List(0)),
      throwsA(isA<ArgumentError>()),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}
