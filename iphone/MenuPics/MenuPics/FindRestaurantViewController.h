//
//  NearbyLocationsViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FindMenuItemViewController.h"


@class MWPhoto;

@interface FindRestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>
{
    IBOutlet UITableViewCell *locationCell;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationsTableData;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) MWPhoto *photoToTag;
@property (nonatomic, strong) id<TagDelegate> tagDelegate;

@end
