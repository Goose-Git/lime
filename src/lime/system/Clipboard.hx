package lime.system;

import lime.graphics.Image;
import lime.math.Rectangle;
import lime.math.Vector2;
import lime._internal.backend.native.NativeCFFI;
import lime.app.Application;
import lime.app.Event;
import lime.system.CFFI;

#if flash
import flash.desktop.Clipboard as FlashClipboard;
#elseif (js && html5)
import lime._internal.backend.html5.HTML5Window;
#end

/**
	Reads and writes text on the system clipboard.
**/
#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(lime._internal.backend.native.NativeCFFI)
@:access(lime.ui.Window)
class Clipboard
{
	/**
		Dispatched when the clipboard text changes.
	**/
	public static var onUpdate = new Event<Void->Void>();

	/**
		The text currently stored in the clipboard.
	**/
	public static var text(get, set):String;

	private static var _text:String;
	@:noCompletion private static var __updated = false;

	private static function __update():Void
	{
		var cacheText = _text;
		_text = null;

		#if (lime_cffi && !macro)
		_text = CFFI.stringValue(NativeCFFI.lime_clipboard_get_text());
		#elseif flash
		if (FlashClipboard.generalClipboard.hasFormat(TEXT_FORMAT))
		{
			_text = FlashClipboard.generalClipboard.getData(TEXT_FORMAT);
		}
		#elseif (js || html5)
		_text = cacheText;
		#end
		__updated = true;

		if (_text != cacheText)
		{
			onUpdate.dispatch();
		}
	}

	// Get & Set Methods
	private static function get_text():String
	{
		// Native clipboard (except Xorg) calls __update when clipboard changes.

		#if (flash || js || html5)
		__update();
		#elseif linux
		// Xorg won't call __update until we call set_text at least once.
		// Details: SDL_x11clipboard.c calls X11_XSetSelectionOwner,
		// registering this app to receive clipboard events.
		if (_text == null)
		{
			__update();

			// Call set_text while changing as little as possible. (Rich text
			// formatting will unavoidably be lost.)
			set_text(_text);
		}
		#elseif (windows || mac)
		if (!__updated)
		{
			// Lime listens for clipboard updates automatically, but if the
			// clipboard has never been updated since before the app started,
			// we need to populate the initial contents manually
			__update();
		}
		#end

		return _text;
	}

	private static function set_text(value:String):String
	{
		var cacheText = _text;
		_text = value;

		#if (lime_cffi && !macro)
		NativeCFFI.lime_clipboard_set_text(value);
		#elseif flash
		FlashClipboard.generalClipboard.setData(TEXT_FORMAT, value);
		#elseif (js && html5)
		var window = Application.current.window;
		if (window != null)
		{
			window.__backend.setClipboard(value);
		}
		#end

		if (_text != cacheText)
		{
			onUpdate.dispatch();
		}

		return value;
	}

	
	public static function getImage():Image{
		//
		// This doesn't currently work on windows/cpp targets
		// it actually only works on Hashlink.
		// it looks like it should work on windows, see:
		// void Clipboard::GetImageSize(Rectangle* size)
		// in SDLSystem.cpp
		//

	#if (!macro && lime_cffi)
	#if !cpp
		var size : Rectangle = new Rectangle(0, 0);
		NativeCFFI.lime_get_clipboard_image_size(size);

		if ( size.x > 0 && size.y > 0 ){
			// There's an image - get it's data
			// Create an image big enought for it
			var image = new Image(null, 0,0, Std.int(size.x), Std.int(size.y) );

			// Now go back to C++ and tell it to fill this image
			NativeCFFI.lime_get_clipboard_image_pixels(image);
			return image;
		}
	#end
	#end
		return null;
	}
}
