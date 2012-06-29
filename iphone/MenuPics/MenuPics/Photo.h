//
//  Photo.h
//  MenuPics
//
//  Created by Christian Deonier on 6/28/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, strong) NSNumber *photoId;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSString *photoFileLocation;
@property (nonatomic, strong) NSString *smallThumbnailUrl;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSNumber *photoAuthorId;
@property (nonatomic, strong) NSString *photoAuthor;
@property (nonatomic, strong) NSNumber *photoPoints;
@property (nonatomic) BOOL votedForPhoto;


@end
