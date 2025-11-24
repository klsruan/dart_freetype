import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:dart_freetype/dart_freetype.dart';

FreetypeBinding freeType = loadFreeType();

void main() async {
  final library = calloc<FT_Library>();

  int err;

  err = freeType.FT_Init_FreeType(library);
  if (err != FT_Err_Ok) {
    print('err on Init FreeType');
  }

  final face = calloc<FT_Face>();

  err = freeType.FT_New_Face(library.value, ('assets/fonts/ARIAL.TTF').asCharP(), 0, face);
  if (err == FT_Err_Unknown_File_Format) {
    print("Font format is unsupported");
  } else if (err == FT_Err_Cannot_Open_Resource) {
    print("Font file is missing or corrupted");
  }

  freeType.FT_Done_Face(face.value);
  freeType.FT_Done_FreeType(library.value);

  print('freetype loaded');
}