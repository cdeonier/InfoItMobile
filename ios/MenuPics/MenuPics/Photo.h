//
//  Photo.h
//  MenuPics
//
//  Created by Christian Deonier on 9/16/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MenuItem;

@interface Photo : NSObject

@property (nonatomic, strong) NSNumber *photoId;

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) NSString *smallThumbnailUrl;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSNumber *points;
@property (nonatomic) BOOL votedForPhoto;

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *menuItemName;
@property (nonatomic, strong) NSString *restaurantName;

@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSNumber *menuItemId;
@property (nonatomic, strong) NSNumber *restaurantId;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (NSMutableArray *)menuItemPhotosFromJson:(id)json;
+ (NSMutableArray *)userPhotosFromJson:(id)json;

+ (Photo *)didTakeNewPhoto:(MenuItem *)menuItem image:(UIImage *)image thumbnail:(UIImage *)thumbnail;

@end
