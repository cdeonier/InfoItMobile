//
//  CurrentMenuViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TakePhotoViewController.h"

@class OrderedDictionary;

@interface CurrentMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TakePhotoDelegate>

@property (nonatomic, strong) OrderedDictionary *menu;

- (void)reloadData;

@end
