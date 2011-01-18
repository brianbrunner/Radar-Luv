//
//  RadarLoveViewController.m
//  RadarLove
//
//  Created by Brian Brunner on 1/12/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "RadarLoveViewController.h"
#import <math.h>

@implementation RadarLoveViewController

@synthesize topView;
@synthesize flashView;
@synthesize username;
@synthesize locationManager;
@synthesize lat1;
@synthesize lon1;
@synthesize lat2;
@synthesize lon2;


+ (NSNumber *)degreesToRads:(NSNumber *)number
{
	return [NSNumber numberWithFloat:[number floatValue]*M_PI/180];
}

- (void)bearingAndDistance
{
	NSLog(@"test");
	NSLog(@"Test: %@", lat2);
	NSLog(@"test");
	if (lat1 && lon1 && lat2 && lon2) {
		
		double pi = [[NSNumber numberWithFloat:M_PI] doubleValue];
		
		NSNumber *dLat = [RadarLoveViewController degreesToRads:[NSNumber numberWithFloat:([lat2 floatValue]-[lat1 floatValue])]];
		NSNumber *dLon = [RadarLoveViewController degreesToRads:[NSNumber numberWithFloat:fabs([lat2 floatValue]-[lat1 floatValue])]];
		NSLog(@"%@ - %@ | %@ - %@", lat1, lon1, lat2, lon2);
		NSNumber *rlat1 = [RadarLoveViewController degreesToRads:lat1];
		NSNumber *rlat2 = [RadarLoveViewController degreesToRads:lat2];
		
		double dPhi = log(tan([rlat2 doubleValue]/2+pi/4)/tan([rlat1 doubleValue]/2+pi/4));
		double q = (dPhi != 0) ? [dLat floatValue]/dPhi : cos([rlat1 doubleValue]);
		
		// if dLon over 180° take shorter rhumb across 180° meridian:
		if (abs([dLon doubleValue]) > M_PI) {
			dLon = [NSNumber numberWithDouble:([dLon doubleValue]>0 ? -(2*pi-[dLon doubleValue]) : (2*pi+[dLon doubleValue]))];
		}
		double d = sqrt([dLat doubleValue]*[dLat doubleValue] + q*q*[dLon doubleValue]*[dLon doubleValue]) * 6731;
		bearing = atan2([dLon doubleValue], dPhi)*180/[[NSNumber numberWithFloat:M_PI] doubleValue];
		NSLog(@"DIST: %g | BEARING: %g", d, bearing);
		
	}
}

- (void) flash
{
	if (!flashing) {
		flashing = YES;
		flashView.backgroundColor = [UIColor whiteColor];
		if (!flashTimer) {
			[flashTimer invalidate];
		}
		flashTimer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(flashUp) userInfo:nil repeats:YES];
		flashView.alpha = 0;
		[[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void) flashUp {
	if (flashView.alpha < 1) {
		flashView.alpha += .12;
	} else {
		[flashTimer invalidate];
		flashTimer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(flashDown) userInfo:nil repeats:YES];
		flashView.alpha = 1;
		[[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void) flashDown {
	if (flashView.alpha > 0) {
		flashView.alpha -= .12;
	} else {
		[flashTimer invalidate];
		flashView.alpha = 0;
		flashing = NO;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (!requestedTweets) {
		requestedTweets = YES;
		waitingForTweets = YES;
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://search.twitter.com/search.json?q=%%40%@+%%23radarluv&geocode=%g%%2C%g%%2C5mi", username, newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSError *error;
		NSURLResponse *response;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		NSData *tweetResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		NSString *tweetString = [[[NSString alloc] initWithData:tweetResponse encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary *tweetData = [tweetString JSONValue];
		NSArray *tweets = [tweetData objectForKey:@"results"];
		if ([tweets count] == 0) {
			topView.backgroundColor = [UIColor blackColor];
			flashView.backgroundColor = [UIColor blackColor];
			flashView.alpha = 1;
			self.view.backgroundColor = [UIColor blackColor];
		} else {
			NSArray *coordinates = [(NSDictionary *)[(NSDictionary *) [tweets objectAtIndex:0] objectForKey:@"geo"] objectForKey:@"coordinates"];
			self.lat2 = [coordinates objectAtIndex:0];
			self.lon2 = [coordinates objectAtIndex:1];
			[locationManager startUpdatingHeading];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			[self flash];
		}
		waitingForTweets = NO;
	} else if (!waitingForTweets) {
		self.lat1 = [NSNumber numberWithDouble:newLocation.coordinate.latitude]; 
		self.lon1 = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
		[self bearingAndDistance];
	}
}

- (IBAction) tap
{
	if (!waitingForTweets) {
		waitingForTweets = YES;
		requestedTweets = NO;
		topView.backgroundColor = [UIColor redColor];
		topView.alpha = 0.5;
		flashView.backgroundColor = [UIColor whiteColor];
		flashView.alpha = 0;
		self.view.backgroundColor = [UIColor blueColor];
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
		[locationManager startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	NSLog(@"%g | %g", newHeading.trueHeading, bearing);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return YES;
}


- (void)viewWillAppear:(BOOL)animated {
	topView.backgroundColor = [UIColor redColor];
	topView.alpha = 0.5;
	flashView.backgroundColor = [UIColor whiteColor];
	flashView.alpha = 0;
	self.view.backgroundColor = [UIColor blueColor];
	waitingForTweets = YES;
	requestedTweets = NO;
    [super viewWillAppear:animated];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
