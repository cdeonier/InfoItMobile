//
//  SavedPhoto.h
//  MenuPics
//
//  Created by Christian Deonier on 6/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@protocol SyncPhotoDelegate;

@interface SavedPhoto : NSManagedObject

//Any SavedPhoto with a *Url property populated needs to download images to complete syncing.
//Any synced photos will have *Url properties as nil.

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSDate *creationDate; 
@property (nonatomic, strong) NSNumber *didUpload;
@property (nonatomic, strong) NSNumber *didDelete;
@property (nonatomic, strong) NSNumber *didTag;
@property (nonatomic, strong) NSNumber *photoId;
@property (nonatomic, strong) NSNumber *suggestedRestaurantId;

@property (nonatomic, strong) id<SyncPhotoDelegate> syncDelegate;

@end
