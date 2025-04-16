#ifndef LIME_SYSTEM_CLIPBOARD_H
#define LIME_SYSTEM_CLIPBOARD_H

#include <graphics/Image.h>

namespace lime {

	class Clipboard {

		public:

			// These are implemented in SDLSystem.cpp

			static const char* GetText ();
			static bool HasText ();
			static bool SetText (const char* text);
			static void GetImageSize(Rectangle* size);
			static void GetImagePixels(Image* dstImage);

	};


}


#endif