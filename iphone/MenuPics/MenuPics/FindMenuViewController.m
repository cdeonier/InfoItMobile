//
//  NearbyLocationsViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "FindMenuViewController.h"

@interface FindMenuViewController ()

@end

@implementation FindMenuViewController

@synthesize responseData = _responseData;

@synthesize tableView = _tableView;
@synthesize locationManager = _locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.responseData = [[NSMutableData alloc] init];
    
    [self initializeLocationManager];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (void)initializeLocationManager 
{
    if (nil == [self locationManager])
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [self restGetNearbyLocations:newLocation];
}

- (void)restGetNearbyLocations:(CLLocation *)location 
{
    NSString *url = [NSString stringWithFormat:@"http://getinfoit.com/services/geocode?latitude=%+.6f&longitude=%+.6f&type=nearby", location.coordinate.latitude, location.coordinate.longitude];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    (void) [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{        
    [self.responseData appendData:data]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{    
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSLog(@"connectionDidFinishLoading");
    NSLog([[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    NSError *myError = nil;
    NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSDictionary *objectAtOne = [[res objectAtIndex:1] objectForKey:@"entity"];
    NSLog([[objectAtOne objectForKey:@"distance"] description]);
    
//    // show all values
//    for(id key in res) {
//        
//        id value = [res objectForKey:key];
//        
//        NSString *keyAsString = (NSString *)key;
//        NSString *valueAsString = (NSString *)value;
//        
//        NSLog(@"key: %@", keyAsString);
//        NSLog(@"value: %@", valueAsString);
//    }
}

@end
