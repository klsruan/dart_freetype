#include <stdint.h>
#include <stdlib.h>
#include <ft2build.h>
#include FT_FREETYPE_H

static FT_Library library = NULL;

typedef struct {
    FT_Face face;
} MyFace;

MyFace* my_new_face_from_memory_ex(uint8_t* data, size_t len, int face_index);
int my_set_pixel_sizes(MyFace* f, int w, int h);

static int is_valid_face(MyFace* f) {
    return f && f->face;
}

int my_init() {
    if (library) return 0;
    return FT_Init_FreeType(&library);
}

MyFace* my_new_face_from_memory(uint8_t* data, size_t len) {
    return my_new_face_from_memory_ex(data, len, 0);
}

MyFace* my_new_face_from_memory_ex(uint8_t* data, size_t len, int face_index) {
    if (!library) return NULL;

    MyFace* f = (MyFace*)malloc(sizeof(MyFace));
    if (!f) return NULL;

    if (FT_New_Memory_Face(library, data, (FT_Long)len, face_index, &f->face)) {
        free(f);
        return NULL;
    }
    return f;
}

int my_set_char_size(MyFace* f, int char_width, int char_height, int hres, int vres) {
    if (!is_valid_face(f)) return 1;
    return FT_Set_Char_Size(f->face, (FT_F26Dot6)char_width, (FT_F26Dot6)char_height, (FT_UInt)hres, (FT_UInt)vres);
}

int my_set_pixel_size(MyFace* f, int px) {
    return my_set_pixel_sizes(f, 0, px);
}

int my_set_pixel_sizes(MyFace* f, int w, int h) {
    if (!is_valid_face(f)) return 1;
    return FT_Set_Pixel_Sizes(f->face, (FT_UInt)w, (FT_UInt)h);
}

void my_set_transform(MyFace* f, int xx, int xy, int yx, int yy, int dx, int dy) {
    if (!is_valid_face(f)) return;
    FT_Matrix m;
    FT_Vector d;
    m.xx = (FT_Fixed)xx;
    m.xy = (FT_Fixed)xy;
    m.yx = (FT_Fixed)yx;
    m.yy = (FT_Fixed)yy;
    d.x = (FT_Pos)dx;
    d.y = (FT_Pos)dy;
    FT_Set_Transform(f->face, &m, &d);
}

int my_get_char_index(MyFace* f, uint32_t charcode) {
    if (!is_valid_face(f)) return 0;
    return (int)FT_Get_Char_Index(f->face, charcode);
}

int my_load_char(MyFace* f, uint32_t codepoint, int load_flags) {
    if (!is_valid_face(f)) return 1;
    return FT_Load_Char(f->face, codepoint, (FT_Int32)load_flags);
}

int my_load_glyph(MyFace* f, int glyph_index, int load_flags) {
    if (!is_valid_face(f)) return 1;
    return FT_Load_Glyph(f->face, (FT_UInt)glyph_index, (FT_Int32)load_flags);
}

int my_render_glyph(MyFace* f, int render_mode) {
    if (!is_valid_face(f)) return 1;
    return FT_Render_Glyph(f->face->glyph, (FT_Render_Mode)render_mode);
}

static uint8_t* copy_current_glyph_bitmap(MyFace* f, int* w, int* h, int* stride, int* left, int* top, int* adv_x, int* adv_y) {
    FT_GlyphSlot g = f->face->glyph;

    if (w) *w = g->bitmap.width;
    if (h) *h = g->bitmap.rows;
    if (stride) *stride = g->bitmap.pitch;
    if (left) *left = g->bitmap_left;
    if (top) *top = g->bitmap_top;
    if (adv_x) *adv_x = (int)g->advance.x;
    if (adv_y) *adv_y = (int)g->advance.y;

    const int rows = g->bitmap.rows;
    const int pitch = g->bitmap.pitch;
    if (rows <= 0 || pitch == 0) return NULL;

    int size = rows * (pitch > 0 ? pitch : -pitch);
    uint8_t* bmp = (uint8_t*)malloc((size_t)size);
    if (!bmp) return NULL;

    // FreeType bitmaps can have a negative pitch; handle both.
    const uint8_t* src = g->bitmap.buffer;
    if (pitch > 0) {
        for (int i = 0; i < size; i++) bmp[i] = src[i];
    } else {
        const int abs_pitch = -pitch;
        for (int y = 0; y < rows; y++) {
            const uint8_t* row = src + (rows - 1 - y) * abs_pitch;
            for (int x = 0; x < abs_pitch; x++) bmp[y * abs_pitch + x] = row[x];
        }
        if (stride) *stride = abs_pitch;
    }
    return bmp;
}

uint8_t* my_get_glyph_bitmap(MyFace* f, int* w, int* h, int* stride, int* left, int* top, int* adv_x, int* adv_y) {
    if (!is_valid_face(f)) return NULL;
    return copy_current_glyph_bitmap(f, w, h, stride, left, top, adv_x, adv_y);
}

int my_get_face_metrics(MyFace* f, int* ascender, int* descender, int* height, int* max_adv_w, int* max_adv_h, int* underline_pos, int* units_per_em) {
    if (!is_valid_face(f)) return 1;
    if (ascender) *ascender = (int)f->face->ascender;
    if (descender) *descender = (int)f->face->descender;
    if (height) *height = (int)f->face->height;
    if (max_adv_w) *max_adv_w = (int)f->face->max_advance_width;
    if (max_adv_h) *max_adv_h = (int)f->face->max_advance_height;
    if (underline_pos) *underline_pos = (int)f->face->underline_position;
    if (units_per_em) *units_per_em = (int)f->face->units_per_EM;
    return 0;
}

uint8_t* my_render_char(MyFace* f, uint32_t codepoint, int* w, int* h, int* stride) {
    if (!is_valid_face(f)) return NULL;
    if (FT_Load_Char(f->face, codepoint, FT_LOAD_RENDER)) return NULL;

    return copy_current_glyph_bitmap(f, w, h, stride, NULL, NULL, NULL, NULL);
}

void my_free_bitmap(uint8_t* p) { if (p) free(p); }
void my_free_face(MyFace* f) { if (!f) return; if (f->face) FT_Done_Face(f->face); free(f); }
void my_done() { if (library) { FT_Done_FreeType(library); library = NULL; } }
