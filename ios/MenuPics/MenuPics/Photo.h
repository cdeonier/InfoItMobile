//
//  Photo.h
//  MenuPics
//
//  Created by Christian Deonier on 9/16/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, strong) NSNumber *photoId;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) NSString *smallThumbnailUrl;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSNumber *points;
@property (nonatomic) BOOL votedForPhoto;

@property (nonatomic, strong) NSString *menuItemName;
@property (nonatomic, strong) NSNumber *menuItemId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSNumber *restaurantId;

@end
