//
//  Photo.h
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Photo : NSObject

@property (nonatomic, strong) CLLocation *location;

+ (void)uploadPhotoAtLocation:(CLLocation *)location image:(UIImage *)image;

@end
