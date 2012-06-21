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

+ (void)uploadPhotoAtLocation:(CLLocation *)location image:(UIImage *)image imageName:(NSString *)imageName photoDate:(NSDate *)date suggestedRestaurantId:(NSNumber *)suggestedRestaurantId;
+ (void)savePhotos:(NSArray *)photoArray atLocation:(CLLocation *)location withRestaurantId:(NSNumber *)restaurantId;

@end
