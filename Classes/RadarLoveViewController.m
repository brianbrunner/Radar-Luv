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
@synthesize flashing;
@synthesize flashView;
@synthesize flashTimer;
@synthesize username;
@synthesize locationManager;
@synthesize lat1;
@synthesize lon1;
@synthesize lat2;
@synthesize lon2;


+ (double) degreesToRads:(double)number
{
	return number*M_PI/180;
}

- (void)bearingAndDistance
{
	if (lat1 && lon1 && lat2 && lon2) {
		double dLat = [RadarLoveViewController degreesToRads:([lat2 doubleValue]-[lat1 doubleValue])];
		double dLon = [RadarLoveViewController degreesToRads:([lon2 doubleValue]-[lon1 doubleValue])];
		double rlat1 = [RadarLoveViewController degreesToRads:[lat1 doubleValue]];
		double rlat2 = [RadarLoveViewController degreesToRads:[lat2 doubleValue]];
		
		double dPhi = log(tan(rlat2/2+M_PI/4)/tan(rlat1/2+M_PI/4));
		NSLog(@"%g", dPhi);
		double q = (!isnan(dLat/dPhi)) ? dLat/dPhi : cos(rlat1);  // E-W line gives dPhi=0
		
		// if dLon over 180° take shorter rhumb across 180° meridian:
		if (abs(dLon) > M_PI) {
			dLon = dLon>0 ? -(2*M_PI-dLon) : (2*M_PI+dLon);
		}
		distance = sqrt(dLat*dLat + q*q*dLon*dLon) * 6371;
		bearing = (atan2(dLon, dPhi)*180/M_PI);
		NSLog(@"%@ %@ | %@ %@ \n %g km | %g dg", lat1, lon1, lat2, lon2, distance, bearing);
	}
}

- (void) flash
{
	if (!flashing) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		flashing = YES;
		flashView.backgroundColor = [UIColor whiteColor];
		if (!flashTimer) {
			[flashTimer invalidate];
		}
		self.flashTimer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(flashUp) userInfo:nil repeats:YES];
		flashView.alpha = 0;
		[[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void)beat
{
	double delay = ((distance/10)*60+.25);
	if (distance < .01) delay = 0.25;
	self.flashTimer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(flash) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
}

- (void) flashUp {
	if (flashView.alpha < .72) {
		flashView.alpha += .12;
	} else {
		[flashTimer invalidate];
		self.flashTimer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(flashDown) userInfo:nil repeats:YES];
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
		[self beat];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (!requestedTweets) {
		requestedTweets = YES;
		waitingForTweets = YES;
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://search.twitter.com/search.json?q=%%40%@+%%23radarluv&geocode=%g%%2C%g%%2C10km", username, newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
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
			[self flash];
		}
		waitingForTweets = NO;
	} else if (!waitingForTweets) {
		self.lat1 = [NSNumber numberWithDouble:manager.location.coordinate.latitude]; 
		self.lon1 = [NSNumber numberWithDouble:manager.location.coordinate.longitude];
		[self bearingAndDistance];
	}
}

- (IBAction) tap
{
	if (!waitingForTweets) {
		if (flashTimer) {
			if ([flashTimer isValid]) {
				[flashTimer invalidate];
				flashing = NO;
			}
		}
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
	if (distance > .01) {
		topView.backgroundColor = [UIColor redColor];
		double currentBearing = newHeading.trueHeading;
		double difference = abs(currentBearing-bearing);
		if (difference > 180) difference = 180 - (difference - 180);
		topView.alpha = 1 - (difference - 5)/180;
		NSLog(@"%g %g", currentBearing, difference);
	} else {
		topView.backgroundColor = [UIColor greenColor];
		topView.alpha = 1;
	}
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
