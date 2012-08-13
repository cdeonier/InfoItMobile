//
//  Photo.h
//  MenuPics
//
//  Created by Christian Deonier on 6/28/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SavedPhoto;

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

- (id)initWithSavedPhoto:(SavedPhoto *)savedPhoto;
+ (void)tagPhoto:(Photo *)photo withMenuItemId:(NSInteger)menuItemId;
+ (void)untagPhoto:(Photo *)photo;

@end
