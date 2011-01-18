//
//  RadarLoveViewController.h
//  RadarLove
//
//  Created by Brian Brunner on 1/12/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JSON.h"

@interface RadarLoveViewController : UIViewController <CLLocationManagerDelegate> {
	IBOutlet UIView *topView;
	IBOutlet UIView *flashView;
	BOOL requestedTweets;
	BOOL waitingForTweets;
	NSString *username;
	NSTimer *flashTimer;
	CLLocationManager *locationManager;
	NSNumber *lat1;
	NSNumber *lat2;
	NSNumber *lon1;
	NSNumber *lon2;
	BOOL flashing;
	float bearing;
	float distance;
}

@property (assign, nonatomic) UIView *topView;
@property (assign, nonatomic) UIView *flashView;
@property (retain) NSTimer *flashTimer;
@property (retain) NSString *username;
@property (retain) CLLocationManager *locationManager;
@property (retain) NSNumber *lat1;
@property (retain) NSNumber *lon1;
@property (retain) NSNumber *lat2;
@property (retain) NSNumber *lon2;
@property BOOL flashing;


+ (float)degreesToRads:(float)number;
- (IBAction) tap;
- (void) flash;
- (void) beat;

@end

