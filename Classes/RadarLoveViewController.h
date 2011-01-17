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
}

@property (assign, nonatomic) UIView *topView;
@property (assign, nonatomic) UIView *flashView;
@property (retain) NSString *username;
@property (retain) CLLocationManager *locationManager;

- (IBAction) tap;
- (void) flash;

@end

