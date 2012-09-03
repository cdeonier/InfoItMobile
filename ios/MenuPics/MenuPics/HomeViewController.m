//
//  HomeViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "HomeViewController.h"

#import "MenuPicsAPIClient.h"
#import "SVProgressHUD.h"

@interface HomeViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation HomeViewController

@synthesize locationManager = _locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIImage *navigationLogo = [UIImage imageNamed:@"nav_logo"];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:navigationLogo];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar.topItem setTitleView:titleView];
    
    [self initializeLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Location

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
    [self getNearbyLocations:newLocation];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Web Service

- (void)getNearbyLocations:(CLLocation *)location
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    void (^didReceiveNearbyLocationsBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didReceiveNearbyLocationsBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"%@", JSON);
        [SVProgressHUD dismiss];
    };
    
    [MenuPicsAPIClient getNearbyLocationsAtLocation:location success:didReceiveNearbyLocationsBlock];
}

@end
