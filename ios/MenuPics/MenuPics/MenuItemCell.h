//
//  MenuItemCell.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;

@interface MenuItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UIImageView *favoriteIcon;
@property (nonatomic, strong) IBOutlet UILabel *numberFavorites;
@property (nonatomic, strong) IBOutlet UILabel *description;

- (void)styleCell:(MenuItem *)menuItem;

@end
