@TestOn('vm')
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_freetype/dart_freetype_ffi.dart';

void main() {
  test('native: dllPath override throws for missing file', () async {
    await expectLater(
      Freetype.create(dllPath: '__this_library_does_not_exist__'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
