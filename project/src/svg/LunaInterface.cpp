// This is the interface for the C++ SVG library (LunaSVG)
// Call this from Haxe Via NativeCFFI.hx

#include <graphics/ImageBuffer.h>
#include <system/System.h>
#include <system/CFFI.h>
#include <system/CFFIPointer.h>
#include <system/Mutex.h>
#include <system/ValuePointer.h>
#include <lunasvg.h>
#include <math/Rectangle.h>
#include <graphics/utils/ImageDataUtil.h>

#include <exception>
#include <string>
#include <list>   

#define _TBYTES _OBJ (_I32 _BYTES)
#define _TARRAYBUFFER _TBYTES
#define _TARRAYBUFFERVIEW _OBJ (_I32 _TARRAYBUFFER _I32 _I32 _I32 _I32)
#define _TAUDIOBUFFER _OBJ (_I32 _I32 _TARRAYBUFFERVIEW _I32 _DYN _DYN _DYN _DYN _DYN _TVORBISFILE)
#define _TIMAGEBUFFER _OBJ (_I32 _TARRAYBUFFERVIEW _I32 _I32 _BOOL _BOOL _I32 _DYN _DYN _DYN _DYN _DYN _DYN)
#define _TIMAGE _OBJ (_TIMAGEBUFFER _BOOL _I32 _I32 _I32 _TRECTANGLE _ENUM _I32 _I32 _F64 _F64 _F64 )


namespace lime {


	// ====================================================
    // Name: get_svg_width
    // ====================================================
	double get_svg_width(const unsigned char* buf, int len) {
		auto document = lunasvg::Document::loadFromData((const char*)buf, len);
		if (!document) return 0.0;
		return document->width();
	}
	
	// ====================================================
    // Name: get_svg_height
    // ====================================================
	double get_svg_height(const unsigned char* buf, int len) {
		auto document = lunasvg::Document::loadFromData((const char*)buf, len);
		if (!document) return 0.0;
		return document->height();
	}	

	// ====================================================
    // Name: load_svg_into_bitmap
    // ====================================================
	int load_svg_into_bitmap_from_data(const unsigned char* buf, int len, int width, int height, ImageBuffer* imageBuffer)
	{
		auto document = lunasvg::Document::loadFromData((const char*)buf, len);
		if (!document) {
			printf("Could NOT load SVG from data\n");
			return -1;
		}

		auto bitmap = document->renderToBitmap(width, height, 0x00000000);
		uint8_t* dstData = (uint8_t*)imageBuffer->data->buffer->b;
		uint8_t* srcData = bitmap.data();

		for (int i = 0; i < width * height; ++i) {
			dstData[4 * i + 0] = srcData[4 * i + 2]; // Blue
			dstData[4 * i + 1] = srcData[4 * i + 1]; // Green
			dstData[4 * i + 2] = srcData[4 * i + 0]; // Red
			dstData[4 * i + 3] = srcData[4 * i + 3]; // Alpha
		}
		return 1;
	}

	// ------------------------------------------------------------------------- PRIMS ---------------------------------

	// ====================================================
	// Name: lime_get_svg_width
	// ====================================================
	int lime_get_svg_width(value bytes) {
		Bytes data(bytes);
		auto document = lunasvg::Document::loadFromData((const char*)data.b, data.length);
		if (!document) return 0;
		return (int)document->width();
	}
	
	HL_PRIM int HL_NAME(hl_get_svg_width)(Bytes* bytes) {
		return (int)get_svg_width(bytes->b, bytes->length);
	}
	
	// ====================================================
	// Name: lime_get_svg_height
	// ====================================================
	int lime_get_svg_height(value bytes) {
		Bytes data(bytes);
		auto document = lunasvg::Document::loadFromData((const char*)data.b, data.length);
		if (!document) return 0;
		return (int)document->height();
	}
	
	HL_PRIM int HL_NAME(hl_get_svg_height)(Bytes* bytes) {
		return (int)get_svg_height(bytes->b, bytes->length);
	}
	
	// ====================================================
    // Name: lime_load_svg_into_bitmap
    // ====================================================
	int lime_load_svg_into_bitmap(value bytes, int width, int height, value buffer)
	{
		ImageBuffer imageBuffer(buffer);
		Bytes data (bytes);

		return load_svg_into_bitmap_from_data(
			(const unsigned char*)data.b,
			data.length,
			width,
			height,
			&imageBuffer
		);
	}
	
	// ====================================================
    // Name: hl_load_svg_into_bitmap
    // ====================================================
	HL_PRIM int HL_NAME(hl_load_svg_into_bitmap)(Bytes* bytes, int width, int height, ImageBuffer* imageBuffer)
	{
		return load_svg_into_bitmap_from_data(bytes->b, bytes->length, width, height, imageBuffer);
	}


	DEFINE_PRIME1(lime_get_svg_width);
	DEFINE_PRIME1(lime_get_svg_height);
	DEFINE_PRIME4(lime_load_svg_into_bitmap);

	DEFINE_HL_PRIM(_I32, hl_get_svg_width, _TBYTES);
	DEFINE_HL_PRIM(_I32, hl_get_svg_height, _TBYTES);
	DEFINE_HL_PRIM(_I32, hl_load_svg_into_bitmap, _TBYTES _I32 _I32 _TIMAGEBUFFER);
}

extern "C" int lime_svg_register_prims () {
	return 0;
}

