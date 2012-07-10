//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 6/28/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Photo.h"
#import "SavedPhoto.h"
#import "User.h"

@implementation Photo

@synthesize photoId = _photoId;
@synthesize photoUrl = _photoUrl;
@synthesize fileName = _fileName;
@synthesize fileLocation = _fileLocation;
@synthesize smallThumbnailUrl = _smallThumbnailUrl;
@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize thumbnail = _thumbnail;
@synthesize authorId = _authorId;
@synthesize author = _photoAuthor;
@synthesize points = _points;
@synthesize votedForPhoto = _votedForPhoto;

- (id)initWithSavedPhoto:(SavedPhoto *)savedPhoto
{
    [self setPhotoId:[savedPhoto photoId]];
    [self setPhotoUrl:[savedPhoto fileUrl]];
    [self setFileName:[savedPhoto fileName]];
    [self setFileLocation:[savedPhoto fileLocation]];
    [self setThumbnailUrl:[savedPhoto thumbnailUrl]];
    [self setThumbnail:[savedPhoto thumbnail]];
    [self setAuthorId:[[User currentUser] userId]];
    [self setAuthor:[[User currentUser] username]];
    
    return self;
}

@end
