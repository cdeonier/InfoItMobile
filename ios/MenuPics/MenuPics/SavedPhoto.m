//
//  SavedPhoto.m
//  MenuPics
//
//  Created by Christian Deonier on 9/17/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "SavedPhoto.h"

#import "MenuItem.h"
#import "MenuPicsAPIClient.h"
#import "MenuPicsDBClient.h"
#import "Photo.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "ViewProfileViewController.h"

@implementation SavedPhoto

@dynamic creationDate;
@dynamic didDelete;
@dynamic didTag;
@dynamic didUpload;
@dynamic fileLocation;
@dynamic fileName;
@dynamic photoUrl;
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
                [MenuPicsAPIClient uploadPhoto:phonePhoto success:[self uploadSuccessBlock:phonePhoto photo:nil] failure:[self uploadFailureBlock:phonePhoto]];
            }
        } else {
            SavedPhoto *phonePhoto = [photosOnPhone objectForKey:key];
            if ([phonePhoto.didDelete boolValue]) {
                [MenuPicsAPIClient deletePhoto:phonePhoto success:nil];
            }
            
            if (!phonePhoto.thumbnail) {
                //download thumbnail
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
            savedPhoto.didUpload = [NSNumber numberWithBool:YES];
            savedPhoto.didDelete = [NSNumber numberWithBool:NO];
            if (savedPhoto.menuItemId) {
                savedPhoto.didTag = [NSNumber numberWithBool:YES];
            } else {
                savedPhoto.didTag = [NSNumber numberWithBool:NO];
            }
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
    savedPhoto.fileLocation = photo.fileLocation;
    savedPhoto.creationDate = photo.creationDate;
    savedPhoto.photoUrl = photo.photoUrl;
    savedPhoto.thumbnailUrl = photo.thumbnailUrl;
    savedPhoto.thumbnail = photo.thumbnail;
    savedPhoto.points = photo.points;
    savedPhoto.menuItemId = photo.menuItemId;
    savedPhoto.menuItemName = photo.menuItemName;
    savedPhoto.restaurantId = photo.restaurantId;
    savedPhoto.restaurantName = photo.restaurantName;
    savedPhoto.didUpload = [NSNumber numberWithBool:NO];
    savedPhoto.didDelete = [NSNumber numberWithBool:NO];
    savedPhoto.didTag = [NSNumber numberWithBool:NO];
    savedPhoto.username = [[User currentUser] username];
    
    return savedPhoto;
}

+ (SavedPhoto *)uploadPhoto:(Photo *)photo
{
    SavedPhoto *savedPhoto = [self savedPhotoFromPhoto:photo];    
    [MenuPicsAPIClient uploadPhoto:savedPhoto success:[self uploadSuccessBlock:savedPhoto photo:photo] failure:[self uploadFailureBlock:savedPhoto]];
    return savedPhoto;
}

+ (void)tagPhoto:(SavedPhoto *)savedPhoto
{
    SuccessBlock success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        savedPhoto.didTag = [NSNumber numberWithBool:YES];
        [MenuPicsDBClient saveContext];
    };
    
    [MenuPicsAPIClient tagPhoto:savedPhoto success:success];
}

+ (UploadSuccessBlock)uploadSuccessBlock:(SavedPhoto *)savedPhoto photo:(Photo *)photo
{
    UploadSuccessBlock success = ^(AFHTTPRequestOperation *operation, id data) {
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        [savedPhoto setPhotoId:[[JSON valueForKey:@"photo"] valueForKey:@"photo_id"]];
        [savedPhoto setPhotoUrl:[[JSON valueForKey:@"photo"] valueForKey:@"photo_original"]];
        [savedPhoto setThumbnailUrl:[[JSON valueForKey:@"photo"] valueForKey:@"photo_thumbnail_200x200"]];
        [savedPhoto setDidUpload:[NSNumber numberWithBool:YES]];
        
        if (photo) {
            [photo setSmallThumbnailUrl:[[JSON valueForKey:@"photo"] valueForKey:@"photo_thumbnail_100x100"]];
            [photo setThumbnailUrl:savedPhoto.thumbnailUrl];
            [photo setPhotoUrl:savedPhoto.photoUrl];
            
            if (photo.menuItem && !photo.menuItem.photoUrl) {
                [photo.menuItem setSmallThumbnailUrl:photo.smallThumbnailUrl];
                [photo.menuItem setThumbnailUrl:photo.thumbnailUrl];
                [photo.menuItem setPhotoUrl:photo.photoUrl];
            }
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[savedPhoto fileLocation] error:nil];
        [savedPhoto setFileLocation:nil];
        
        [MenuPicsDBClient saveContext];
        
        if (savedPhoto.menuItemId) {
            [self tagPhoto:savedPhoto];
        }
    };
    
    return success;
}

+ (UploadFailureBlock)uploadFailureBlock:(SavedPhoto *)savedPhoto
{
    UploadFailureBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
        NSLog(@"%@", [error description]);
    };
    return failure;
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
