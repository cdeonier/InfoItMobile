//
//  PublicThumbnail.h
//  MenuPics
//
//  Created by Christian Deonier on 7/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@interface SmallThumbnail : UIView

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *points;

@end
