//
//  SavedPhoto.m
//  MenuPics
//
//  Created by Christian Deonier on 9/17/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "SavedPhoto.h"

#import "MenuPicsAPIClient.h"
#import "MenuPicsDBClient.h"
#import "Photo.h"
#import "User.h"
#import "ViewProfileViewController.h"

@implementation SavedPhoto

@dynamic creationDate;
@dynamic didDelete;
@dynamic didTag;
@dynamic didUpload;
@dynamic fileLocation;
@dynamic fileName;
@dynamic fileUrl;
@dynamic latitude;
@dynamic longitude;
@dynamic menuItemId;
@dynamic menuItemName;
@dynamic photoId;
@dynamic points;
@dynamic restaurantId;
@dynamic restaurantName;
@dynamic thumbnail;
@dynamic thumbnailUrl;
@dynamic username;

+ (void)syncPhotos:(NSMutableArray *)photos viewController:(ViewProfileViewController *)viewController
{
    NSMutableDictionary *photosOnServer = [[NSMutableDictionary alloc] initWithCapacity:photos.count];
    for (Photo *photo in photos) {
        [photosOnServer setObject:photo forKey:photo.fileName];
    }
    
    NSString *predicateString = [NSString stringWithFormat:@"(username == '%@')", [[User currentUser] username]];
    NSMutableArray *savedPhotos = [MenuPicsDBClient fetchResultsFromDB:@"SavedPhoto" withPredicate:predicateString];
    NSMutableDictionary *photosOnPhone = [[NSMutableDictionary alloc] initWithCapacity:savedPhotos.count];
    for (SavedPhoto *savedPhoto in savedPhotos) {
        [photosOnPhone setObject:savedPhoto forKey:savedPhoto.fileName];
    }
    
    for (NSString *key in photosOnPhone.keyEnumerator) {
        if (![photosOnServer objectForKey:key]) {
            SavedPhoto *phonePhoto = [photosOnPhone objectForKey:key];
            if ([phonePhoto.didUpload boolValue]) {
                [MenuPicsDBClient deleteObject:phonePhoto];
            } else {
                [MenuPicsAPIClient uploadPhoto:phonePhoto];
            }
        } else {
            SavedPhoto *phonePhoto = [photosOnPhone objectForKey:key];
            if ([phonePhoto.didDelete boolValue]) {
                [MenuPicsAPIClient deletePhoto:phonePhoto success:nil];
            }
            
            if (phonePhoto.thumbnail == nil) {
                void (^didFetchThumbnailBlock)(UIImage *);
                didFetchThumbnailBlock = ^(UIImage *image) {
                    phonePhoto.thumbnail = image;
                    [MenuPicsDBClient saveContext];
                    [viewController addNewPhoto:phonePhoto];
                };
                [MenuPicsAPIClient downloadPhotoThumbnail:phonePhoto success:didFetchThumbnailBlock];
            }
        }
    }
    
    for (NSString *key in photosOnServer.keyEnumerator) {
        if (![photosOnPhone objectForKey:key]) {
            Photo *missingPhotoOnPhone = [photosOnServer objectForKey:key];
            SavedPhoto *savedPhoto = [SavedPhoto savedPhotoFromPhoto:missingPhotoOnPhone];
            [MenuPicsDBClient saveContext];
            
            void (^didFetchThumbnailBlock)(UIImage *);
            didFetchThumbnailBlock = ^(UIImage *image) {
                savedPhoto.thumbnail = image;
                [MenuPicsDBClient saveContext];
                [viewController addNewPhoto:savedPhoto];
            };
            [MenuPicsAPIClient downloadPhotoThumbnail:savedPhoto success:didFetchThumbnailBlock]; 
        } else {
            Photo *photoOnServer = (Photo *)[photosOnServer objectForKey:key];
            SavedPhoto *photoOnPhone = [photosOnPhone objectForKey:key];
            photoOnPhone.points = photoOnServer.points;
            [MenuPicsDBClient saveContext];
        }
    }
}

+ (SavedPhoto *)savedPhotoFromPhoto:(Photo *)photo
{
    SavedPhoto *savedPhoto = (SavedPhoto *)[MenuPicsDBClient generateManagedObject:@"SavedPhoto"];
    savedPhoto.photoId = photo.photoId;
    savedPhoto.fileName = photo.fileName;
    savedPhoto.creationDate = photo.creationDate;
    savedPhoto.fileUrl = photo.photoUrl;
    savedPhoto.thumbnailUrl = photo.thumbnailUrl;
    savedPhoto.points = photo.points;
    savedPhoto.menuItemId = photo.menuItemId;
    savedPhoto.menuItemName = photo.menuItemName;
    savedPhoto.restaurantId = photo.restaurantId;
    savedPhoto.restaurantName = photo.restaurantName;
    savedPhoto.didUpload = [NSNumber numberWithBool:YES];
    savedPhoto.didDelete = [NSNumber numberWithBool:NO];
    savedPhoto.username = [[User currentUser] username];
    
    if (savedPhoto.menuItemId) {
        savedPhoto.didTag = [NSNumber numberWithBool:YES];
    } else {
        savedPhoto.didTag = [NSNumber numberWithBool:NO];
    }
    
    return savedPhoto;
}

@end

@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end
