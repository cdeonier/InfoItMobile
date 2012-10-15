//
//  PopularViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TakePhotoViewController.h"

@class OrderedDictionary;

@interface PopularMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TakePhotoDelegate>

@property (nonatomic, strong) NSArray *popularItems;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)reloadData;

@end
