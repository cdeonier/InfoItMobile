//
//  NearbyLocationsViewController.h
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FindMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)initializeLocationManager;

@end
