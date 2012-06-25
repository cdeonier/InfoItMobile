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
#import "Photo.h"
#import "ViewProfileViewController.h"

@implementation SavedPhoto (Syncing)

+ (void)downloadPhotoImages:(SavedPhoto *)photo {
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.fileUrl]];
    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailUrl]];
    
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest success:^(UIImage *image) {
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
        NSString *filePath = [photosDirectory stringByAppendingPathComponent:[photo fileName]];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        [photo setFileLocation:filePath];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        [imageData writeToFile:filePath atomically:YES];
        
        if ([self hasDownloadedImages:photo]) {
            [self finalizeDownloadedPhoto:photo];
            [photo.syncDelegate didSyncPhoto:photo];
        }
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
    
    if ([fileManager fileExistsAtPath:filePath] && [photo thumbnailUrl]) {
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
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[photo latitude] doubleValue] longitude:[[photo longitude] doubleValue]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:[photo fileLocation]];
    UIImage *image = [UIImage imageWithData:imageData];
    
    
    [Photo uploadPhotoAtLocation:location image:image imageName:[photo fileName] photoDate:[photo creationDate] suggestedRestaurantId:[photo suggestedRestaurantId]];
}

@end
