//
//  MenuDelegate.h
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuDelegate <NSObject>

@optional
- (UIView *)viewForLeftMenu;
- (UIView *)viewForRightMenu;

@end

