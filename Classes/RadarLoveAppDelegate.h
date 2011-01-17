//
//  RadarLoveAppDelegate.h
//  RadarLove
//
//  Created by Brian Brunner on 1/12/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RadarLoveViewController;

@interface RadarLoveAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RadarLoveViewController *viewController;
	NSTimer *runTimer;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RadarLoveViewController *viewController;
@property (nonatomic, retain) NSTimer *runTimer;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

