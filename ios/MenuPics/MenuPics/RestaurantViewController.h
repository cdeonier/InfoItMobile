//
//  RestaurantViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Restaurant;

@interface RestaurantViewController : UIViewController

@property (nonatomic, strong) Restaurant *restaurant;

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;

- (void)reloadData;

@end
