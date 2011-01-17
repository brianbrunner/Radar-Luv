//
//  RadarLoveViewController.m
//  RadarLove
//
//  Created by Brian Brunner on 1/12/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "RadarLoveViewController.h"

@implementation RadarLoveViewController

@synthesize topView;
@synthesize flashView;
@synthesize username;
@synthesize locationManager;

- (void) flash
{
	flashView.backgroundColor = [UIColor whiteColor];
	if (!flashTimer) {
		[flashTimer invalidate];
	}
	flashTimer = [NSTimer timerWithTimeInterval:.03 target:self selector:@selector(flashUp) userInfo:nil repeats:YES];
	flashView.alpha = 0;
	[[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
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
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (!requestedTweets) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://search.twitter.com/search.json?q=%%40%@+%%23radarluv&geocode=%g%%2C%g%%2C5mi", username, newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
		NSLog(@"http://search.twitter.com/search.json?q=%%40%@+%%23radarluv&geocode=%g%%2C%g%%2C5mi", username, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSError *error;
		NSURLResponse *response;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		NSData *tweetResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		NSString *tweetString = [[[NSString alloc] initWithData:tweetResponse encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary *tweetData = [tweetString JSONValue];
		NSArray *tweets = [tweetData objectForKey:@"results"];
		NSLog(@"%@", tweets);
		if ([tweets count] == 0) {
			topView.backgroundColor = [UIColor blackColor];
			flashView.backgroundColor = [UIColor blackColor];
			flashView.alpha = 1;
			self.view.backgroundColor = [UIColor blackColor];
		} else {
			[locationManager startUpdatingHeading];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			[self flash];
		}
		requestedTweets = YES;
	} else if (!waitingForTweets) {
		
	}
}

- (IBAction) tap
{
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

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	
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
