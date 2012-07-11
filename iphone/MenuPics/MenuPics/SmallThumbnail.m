//
//  PublicThumbnail.m
//  MenuPics
//
//  Created by Christian Deonier on 7/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SmallThumbnail.h"

@implementation SmallThumbnail

@synthesize view = _view;
@synthesize thumbnail = _thumbnail;
@synthesize points = _points;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SmallThumbnail" owner:self options:nil];
        [self addSubview:_view];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
