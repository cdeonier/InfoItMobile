//
//  SavedPhoto.h
//  MenuPics
//
//  Created by Christian Deonier on 9/17/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo;
@class ViewProfileViewController;

@interface SavedPhoto : NSManagedObject

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *didDelete;
@property (nonatomic, strong) NSNumber *didTag;
@property (nonatomic, strong) NSNumber *didUpload;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *menuItemId;
@property (nonatomic, strong) NSString *menuItemName;
@property (nonatomic, strong) NSNumber *photoId;
@property (nonatomic, strong) NSNumber *points;
@property (nonatomic, strong) NSNumber *restaurantId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *username;

+ (void)syncPhotos:(NSMutableArray *)photos viewController:(ViewProfileViewController *)viewController;

+ (SavedPhoto *)savedPhotoFromPhoto:(Photo *)photo;
+ (SavedPhoto *)uploadPhoto:(Photo *)photo;
+ (void)tagPhoto:(SavedPhoto *)savedPhoto;

@end

@interface ImageToDataTransformer : NSValueTransformer {
}
@end
