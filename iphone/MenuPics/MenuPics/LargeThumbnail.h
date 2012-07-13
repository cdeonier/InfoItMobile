//
//  LargeThumbnail.h
//  MenuPics
//
//  Created by Christian Deonier on 7/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargeThumbnail : UIView

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *points;
@property (nonatomic, strong) IBOutlet UIView *pointsBackground;

@end
