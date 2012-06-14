//
//  ViewProfileViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

enum {
    ProfileTab = 1,
    PhotosTab = 2
};
typedef NSInteger ViewProfileTab;

@interface ViewProfileViewController : UIViewController <UITabBarDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

//Profile

//Photos
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) GMGridView *photosGridView;

@end
