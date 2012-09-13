//
//  EmptyMenuCell.h
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;

@interface EmptyMenuItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *addPhotoButton;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UIImageView *favoriteIcon;
@property (nonatomic, strong) IBOutlet UILabel *numberFavorites;
@property (nonatomic, strong) IBOutlet UILabel *description;

- (void)styleCell:(MenuItem *)menuItem;

@end
