//
//  CurrentMenuViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderedDictionary;

@interface CurrentMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) OrderedDictionary *menu;

- (void)reloadData;

@end
