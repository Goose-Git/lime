#include <stdio.h>

// --------------------------------------
// 1) Overriding SDL's appDelegate
// to provide access to didFinishLaunchingWithOptions
// --------------------------------------
#import <UIKit/UIKit.h>

::if SET_FIREBASE_INTEGRATION::
// Import Firebase (if you want to use Firebase):
#import <GooseLogin/GLogin.h>
//#import <FirebaseCore/FirebaseCore.h>
::end::

// refers to the copy of SDL_uikitappdelegate.h also in goose templates:
#import "SDL_uikitappdelegate.h"

// --- Subclass SDLUIKitDelegate ---
@interface GooseDelegate : SDLUIKitDelegate
@end

@implementation GooseDelegate

	// -------------------------------------
	// didFinishLaunchingWithOptions 
	// -------------------------------------
	- (BOOL)application:(UIApplication *)application
		didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		// Call SDL’s normal setup first
		BOOL ret = [super application:application didFinishLaunchingWithOptions:launchOptions];
		
		// Your custom code goes here:
		NSLog(@"GooseDelegate is now in control!");

	::if SET_FIREBASE_INTEGRATION::
		// init Firebase:
		//[FIRApp configure];
		GLogin_init(NULL);  // NULL is correct here, not nil
		
	::end::

		return ret;
	}

@end

// --- Category to tell SDL to use GooseDelegate ---
@interface SDLUIKitDelegate (extra)
@end

@implementation SDLUIKitDelegate (extra)
	// -------------------------------------
	// getAppDelegateClassName
	// Tells SDL to use our overriden delegate instead of the base SDLUIKitDelegate.
	// -------------------------------------
	+ (NSString *)getAppDelegateClassName 
	{
		return @"GooseDelegate";
	}
@end


// --------------------------------------
// 2) Existing Haxe/Lime bridging code
//    (Unchanged from lime's original Main.mm template)
// --------------------------------------
extern "C" const char *hxRunLibrary ();
extern "C" void hxcpp_set_top_of_stack ();

extern "C" int zlib_register_prims ();
extern "C" int lime_register_prims ();
::foreach ndlls::::if (registerStatics)::
extern "C" int ::nameSafe::_register_prims ();::end::::end::


extern "C" int SDL_main (int argc, char *argv[]) {

	hxcpp_set_top_of_stack ();

	zlib_register_prims ();
	lime_register_prims ();
	::foreach ndlls::::if (registerStatics)::
	::nameSafe::_register_prims ();::end::::end::

	const char *err = NULL;
	err = hxRunLibrary ();

	if (err) {

		printf ("Error %s\n", err);
		return -1;

	}

	return 0;

}