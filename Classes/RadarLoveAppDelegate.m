//
//  RadarLoveAppDelegate.m
//  RadarLove
//
//  Created by Brian Brunner on 1/12/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "RadarLoveAppDelegate.h"
#import "RadarLoveViewController.h"

@implementation RadarLoveAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize runTimer;
@synthesize locationManager;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	//Get the bundle path
	NSString *bPath = [[NSBundle mainBundle] bundlePath];
	NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
	
	//Get the Preferences Array from the dictionary
	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
	NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
	NSDictionary *userDict = [preferencesArray objectAtIndex:0];

	viewController.username = [userDict objectForKey:@"DefaultValue"];
	NSLog(@"%@", viewController.username);
    viewController.view.backgroundColor = [UIColor blueColor];
	self.locationManager = [[CLLocationManager alloc] init];
	viewController.locationManager = locationManager;
	locationManager.delegate = viewController;
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	
    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
	[self.window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    if (viewController.flashTimer) {
		if ([viewController.flashTimer isValid]) {
			[viewController.flashTimer invalidate];
			viewController.flashing = NO;
		}
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[viewController flash];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
