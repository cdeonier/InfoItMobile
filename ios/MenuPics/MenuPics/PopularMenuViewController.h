//
//  PopularViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderedDictionary;

@interface PopularMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *popularItems;

-(void)reloadData;

@end
