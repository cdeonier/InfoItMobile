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
@property (nonatomic, strong) NSNumber *restaurantId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSNumber *menuItemId;
@property (nonatomic, strong) NSString *menuItemName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *points;

//Transients
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) id<SyncPhotoDelegate> syncDelegate;

+ (SavedPhoto *)photoWithFilename:(NSString *)fileName;

@end
