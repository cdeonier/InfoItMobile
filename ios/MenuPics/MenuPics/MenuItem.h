//
//  MenuItem.h
//  MenuPics
//
//  Created by Christian Deonier on 5/12/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSNumber *entityId;
@property (nonatomic, strong) NSNumber *restaurantId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *photoCount;
@property (nonatomic, strong) NSString *profilePhotoUrl;
@property (nonatomic, strong) NSString *smallThumbnailUrl;
@property (nonatomic, strong) NSString *largeThumbnailUrl;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *menuType;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) BOOL isLiked;

- (MenuItem *)initWithJson:(id)json;

@end
