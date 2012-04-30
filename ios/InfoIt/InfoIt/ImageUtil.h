//
//  ImageUtil.h
//  InfoIt
//
//  Created by Christian Deonier on 4/7/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject

+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
