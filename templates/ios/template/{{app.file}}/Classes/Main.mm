#include <stdio.h>


// --------------------------------------
// Main.mm
// --------------------------------------
// --------------------------------------
// 1) Overriding SDL's appDelegate
// to provide access to didFinishLaunchingWithOptions
// --------------------------------------
#import <UIKit/UIKit.h>

::if SET_FIREBASE_INTEGRATION::
// Import Firebase (if you want to use Firebase):
#import <GooseFirebase/GFirebase.h>
//#import <FirebaseCore/FirebaseCore.h>
::end::

::if SET_FACEBOOK_INTEGRATION::
// Import Facebook (if you want to use Facebook):
#import <GooseFacebook/GFacebook.h>
::end::

// refers to the copy of SDL_uikitappdelegate.h also in goose templates:
#import "SDL_uikitappdelegate.h"

// forward declaring this function so we can use it in CNativeFunctions
::if SET_INERTIA_FUNCTIONS::
namespace inertia
{
	void onResume();
}
::end::

// --- Subclass SDLUIKitDelegate ---
@interface GooseDelegate : SDLUIKitDelegate
@end

// storing universal link in deep_link_url for retrieval
static void GooseStoreUniversalLink(NSUserActivity *userActivity)
{
	if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb])
	{
		return;
	}

	NSURL *url = userActivity.webpageURL;

	if (url == nil)
	{
		return;
	}

	NSString *urlString = [url absoluteString];

	NSLog(@"[UniversalLink] Stored URL: %@", urlString);

	[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"deep_link_url"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@implementation GooseDelegate

	// -------------------------------------
	// didFinishLaunchingWithOptions  (override)
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
		GFirebase_init();
	::end::

	::if SET_FACEBOOK_INTEGRATION::
		// init Facebook:
		GFacebook_initFB(application,launchOptions);
	::end::

		return ret;
	}

	// -------------------------------------
	// openURL (override)
	// -------------------------------------
	- (BOOL)application:(UIApplication *)app
				openURL:(NSURL *)url
				options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
	{
		BOOL handled = false;
		
		NSLog(@"GooseDelegate openUrl");
		// this function handles incoming callbacks when facebook logs in in browser, i think
	::if SET_FACEBOOK_INTEGRATION::
		handled = GFacebook_handleOpenURL(app,url,options);
	::end::
		NSLog(@"GooseDelegate openUrl 2");

		// Also let SDL handle it if Facebook didn’t
		return handled || [super application:app
									openURL:url
									options:options];
	}

	// -------------------------------------
	// continueUserActivity
	// Handles Universal Links into this app
	// -------------------------------------
	- (BOOL)application:(UIApplication *)application
	continueUserActivity:(NSUserActivity *)userActivity
	restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
	{
		BOOL isUniversalLink = [userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb];

		if (isUniversalLink)
		{
			GooseStoreUniversalLink(userActivity);

			// Notify Haxe that new deep link params are available.
			::if SET_INERTIA_FUNCTIONS::
				inertia::onResume();
			::end::
			return YES;
		}

		// Notify Haxe that new deep link params are available.
		::if SET_INERTIA_FUNCTIONS::
			inertia::onResume();
		::end::
		
		return [super application:application
			continueUserActivity:userActivity
			restorationHandler:restorationHandler];
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
