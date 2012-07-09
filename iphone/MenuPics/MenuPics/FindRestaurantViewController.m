//
//  NearbyLocationsViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "FindRestaurantViewController.h"
#import "MenuViewController.h"
#import "FindMenuItemViewController.h"
#import "UIColor+ExtendedColor.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Location.h"
#import "TakePhotoViewController.h"
#import "SVProgressHUD.h"

@interface FindRestaurantViewController ()

@end

@implementation FindRestaurantViewController

@synthesize tableView = _tableView;
@synthesize locationManager = _locationManager;
@synthesize locationsTableData = _locationsTableData;
@synthesize searchBar = _searchBar;
@synthesize photoId = _photoId;

#pragma mark ViewController

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
    
    self.locationsTableData = [[NSMutableArray alloc] init];
    
    [self initializeLocationManager];
    
    [self setPhotoId:207];
    
    if ([self photoId]) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        
        UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        [instructions setText:@"Choose photo's location"];
        [instructions setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:12.0]];
        [instructions setTextColor:[UIColor whiteColor]];
        [instructions setBackgroundColor:[UIColor lightGrayColor]];
        [instructions setTextAlignment:UITextAlignmentCenter];
        [headerView addSubview:instructions];
        
        self.tableView.tableHeaderView = headerView;
    } 
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setTitle:@"Restaurants"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
        cell = locationCell;
        locationCell = nil;
    }
    
    Location *location = [self.locationsTableData objectAtIndex:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = [location name];
    UILabel *distance = (UILabel *)[cell viewWithTag:2];
    distance.text = [[NSString alloc] initWithFormat:@"%@%@", [[location distance] description], @" miles"];
    UIImageView *thumbnail = (UIImageView *)[cell viewWithTag:3];
    [thumbnail setImageWithURL:[NSURL URLWithString:[location thumbnailUrl]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *location = [self.locationsTableData objectAtIndex:indexPath.row];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Restaurants" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self photoId]) {
        FindMenuItemViewController *viewController = [[FindMenuItemViewController alloc] initWithNibName:@"FindMenuItemViewController" bundle:nil];
        viewController.restaurantIdentifier = (NSInteger *)[location.entityId intValue];
        viewController.photoId = self.photoId;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        MenuViewController *viewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        viewController.restaurantIdentifier = location.entityId;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locationsTableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
    [SVProgressHUD showWithStatus:@"Loading"];
    
    if ([self photoId]) {
        [self getSuggestedLocations:newLocation];
    } else {
        [self getNearbyLocations:newLocation];
    }
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark REST Calls

- (void)getNearbyLocations:(CLLocation *)location 
{ 
    NSString *urlString = [NSString stringWithFormat:@"http://getinfoit.com/services/geocode?latitude=%+.6f&longitude=%+.6f&type=nearby", location.coordinate.latitude, location.coordinate.longitude];;
    
    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)                                
    { 
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (id locationJson in JSON) {
            NSDictionary *location = [locationJson valueForKey:@"entity"];
            
            //Only deal with restaurants at this point
            NSString *entitySubType = [location valueForKey:@"entity_sub_type"];
            if ([entitySubType isEqualToString:@"Restaurant"]) {
                Location *locationRecord = [[Location alloc] init];
                
                NSString *name = [location valueForKey:@"name"];
                NSNumber *distance = [location valueForKey:@"distance"];
                NSNumber *entityId = [location valueForKey:@"id"];
                NSString *thumbnailUrl = [location valueForKey:@"profile_photo_thumbnail_100x100"];
                
                [locationRecord setName:name];
                [locationRecord setDistance:distance];
                [locationRecord setEntityId:entityId];
                [locationRecord setThumbnailUrl:thumbnailUrl];
                
                [locations addObject:locationRecord];
            }
        }
        
        self.locationsTableData = locations;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
    {
        NSLog(@"Error: %@", [error description]);
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
    }];
    [operation start];

}

- (void)getSuggestedLocations:(CLLocation *)location 
{ 
    NSString *urlString = [NSString stringWithFormat:@"https://infoit.heroku.com/services/geocode_near_photo/%d?latitude=%+.6f&longitude=%+.6f&type=nearby", [self photoId], location.coordinate.latitude, location.coordinate.longitude];;
    
    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)                                
    { 
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        
        id suggestedRestaurantJSON = [[[JSON valueForKey:@"nearby_suggested_restaurant"] valueForKey:@"entity_restaurant"] objectAtIndex:0];

        Location *suggestedRestaurant = [[Location alloc] init];
        [suggestedRestaurant setName:[suggestedRestaurantJSON valueForKey:@"name"]];
        [suggestedRestaurant setDistance:[suggestedRestaurantJSON valueForKey:@"distance"]];
        [suggestedRestaurant setEntityId:[suggestedRestaurantJSON valueForKey:@"id"]];
        [suggestedRestaurant setThumbnailUrl:[suggestedRestaurantJSON valueForKey:@"profile_photo_thumbnail_100x100"]];
        [locations addObject:suggestedRestaurant];

        for (id restaurantJSON in [[JSON valueForKey:@"nearby_user"] valueForKey:@"entity_restaurant"]) {
            Location *restaurant = [[Location alloc] init];
            [restaurant setName:[restaurantJSON valueForKey:@"name"]];
            [restaurant setDistance:[restaurantJSON valueForKey:@"distance"]];
            [restaurant setEntityId:[restaurantJSON valueForKey:@"id"]];
            [restaurant setThumbnailUrl:[restaurantJSON valueForKey:@"profile_photo_thumbnail_100x100"]];
            
            NSString *entityType = [restaurantJSON valueForKey:@"entity_sub_type"];
            
            if (![[restaurant entityId] isEqualToNumber:[suggestedRestaurant entityId]] && [entityType isEqualToString:@"Restaurant"]) {
                [locations addObject:restaurant];
            }
        }

        self.locationsTableData = locations;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
    {
        NSLog(@"Error: %@", [error description]);
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
    }];
    [operation start];
    
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
