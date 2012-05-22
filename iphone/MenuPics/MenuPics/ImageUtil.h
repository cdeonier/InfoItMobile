//
//  ImageUtil.h
//  MenuPics
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize; 
+ (NSArray *)getSweepImageArray;

@end
