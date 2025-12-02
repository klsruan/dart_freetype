#include <stdint.h>
#include <stdlib.h>
#include <ft2build.h>
#include FT_FREETYPE_H

static FT_Library library = NULL;

typedef struct {
    FT_Face face;
} MyFace;

int main() {
    return 0;
}

int my_init() {
    if (library) return 0;
    return FT_Init_FreeType(&library);
}

MyFace* my_new_face_from_memory(uint8_t* data, size_t len) {
    if (!library) return NULL;

    MyFace* f = (MyFace*)malloc(sizeof(MyFace));
    if (!f) return NULL;

    if (FT_New_Memory_Face(library, data, (FT_Long)len, 0, &f->face)) {
        free(f);
        return NULL;
    }
    return f;
}

int my_set_pixel_size(MyFace* f, int px) {
    if (!f || !f->face) return 1;
    return FT_Set_Pixel_Sizes(f->face, 0, (FT_UInt)px);
}

uint8_t* my_render_char(MyFace* f, uint32_t codepoint, int* w, int* h, int* stride) {
    if (!f || !f->face) return NULL;
    if (FT_Load_Char(f->face, codepoint, FT_LOAD_RENDER)) return NULL;

    FT_GlyphSlot g = f->face->glyph;
    *w = g->bitmap.width;
    *h = g->bitmap.rows;
    *stride = g->bitmap.pitch;

    uint8_t* bmp = (uint8_t*)malloc(g->bitmap.rows * g->bitmap.pitch);
    if (!bmp) return NULL;

    for (int i = 0; i < g->bitmap.rows * g->bitmap.pitch; i++)
        bmp[i] = g->bitmap.buffer[i];

    return bmp;
}

void my_free_bitmap(uint8_t* p) { if (p) free(p); }
void my_free_face(MyFace* f) { if (!f) return; if (f->face) FT_Done_Face(f->face); free(f); }
void my_done() { if (library) { FT_Done_FreeType(library); library = NULL; } }
