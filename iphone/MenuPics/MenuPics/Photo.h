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

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) UIImage *smallThumbnail;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic) BOOL isSelected;

+ (void)uploadPhotoAtLocation:(CLLocation *)location image:(UIImage *)image photoDate:(NSDate *)date;
+ (void)savePhotos:(NSArray *)photoArray creationDate:(NSDate *)date creationLocation:(CLLocation *)location;

@end
