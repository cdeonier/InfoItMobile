//
//  SavedPhoto+Syncing.m
//  MenuPics
//
//  Created by Christian Deonier on 6/23/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SavedPhoto+Syncing.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MenuPicsAPIClient.h"
#import "User.h"
#import "ViewProfileViewController.h"

@implementation SavedPhoto (Syncing)

+ (void)downloadPhotoImages:(SavedPhoto *)photo {
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.fileUrl]];
    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailUrl]];
    
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest success:^(UIImage *image) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
        NSString *filePath = [photosDirectory stringByAppendingPathComponent:[photo fileName]];
        
        [photo setFileLocation:filePath];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:filePath atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self hasDownloadedImages:photo]) {
                    [self finalizeDownloadedPhoto:photo];
                    [photo.syncDelegate didSyncPhoto:photo];
                }
            });
        });
    }];
    
    AFImageRequestOperation *thumbnailOperation = [AFImageRequestOperation imageRequestOperationWithRequest:thumbnailRequest success:^(UIImage *image) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        [photo setThumbnail:image];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        if ([self hasDownloadedImages:photo]) {
            [self finalizeDownloadedPhoto:photo];
            [photo.syncDelegate didSyncPhoto:photo];
        }
    }];
    
    [imageOperation start];
    [thumbnailOperation start];
}

+ (BOOL)hasDownloadedImages:(SavedPhoto *)photo {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
    
    NSString *filePath = [photosDirectory stringByAppendingPathComponent:[photo fileName]];
    
    if ([fileManager fileExistsAtPath:filePath] && [photo thumbnail]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)finalizeDownloadedPhoto:(SavedPhoto *)photo {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    [photo setFileUrl:nil];
    [photo setThumbnailUrl:nil];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
}

+ (void)uploadPhoto:(SavedPhoto *)photo
{
    NSLog(@"Uploading photo...");
    User *currentUser = [User currentUser];
    if (currentUser) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if ([photo latitude]) {
            [mutableParameters setObject:[photo latitude] forKey:@"photo[lat]"];
            [mutableParameters setObject:[photo longitude] forKey:@"photo[lng]"];
        }
        
        if ([photo restaurantId])
            [mutableParameters setObject:[photo restaurantId] forKey:@"photo[suggested_restaurant_id]"];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // e.g., set for mysql date strings
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSString *mysqlGMTString = [formatter stringFromDate:[photo creationDate]];
        [mutableParameters setObject:mysqlGMTString forKey:@"photo[taken_at]"];
        
        NSData *imageData = [NSData dataWithContentsOfFile:[photo fileLocation]];
        
        NSString *path = [NSString stringWithFormat:@"/services/photos?access_token=%@", [currentUser accessToken]];
        
        NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"photo[photo_attachment]" fileName:[photo fileName] mimeType:@"image/jpeg"];
        }];
        
        AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"Upload Success");
            NSLog(@"JSON: %@", JSON);
            
            if (JSON) {
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
                [request setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName = %@", [photo fileName]];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
                if (mutableFetchResults == nil) {
                    NSLog(@"Error fetching from Core Data");
                }
                
                assert([mutableFetchResults count] > 0);
                assert([[JSON valueForKey:@"photo"] valueForKey:@"photo_id"] != nil);
                
                SavedPhoto *uploadedPhoto = [mutableFetchResults objectAtIndex:0];
                [uploadedPhoto setPhotoId:[JSON valueForKey:@"photo_id"]];
                [uploadedPhoto setDidUpload:[NSNumber numberWithBool:YES]];
                if (![context save:&error]) {
                    NSLog(@"Error saving to Core Data");
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Upload Failure");
            NSLog([error description]);
        }];
        [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    } else {
        NSLog(@"Cannot upload photo; no user logged in");
    }
}

+ (void)claimPhotos
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == nil"];
    [request setPredicate:predicate];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];

    if ([mutableFetchResults count] > 0) {
        for (SavedPhoto *photo in mutableFetchResults) {
            [photo setUsername:[[User currentUser] username]];
        }

        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
    }
}

@end
