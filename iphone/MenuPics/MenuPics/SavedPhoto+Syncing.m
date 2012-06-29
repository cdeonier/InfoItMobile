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

+ (void)downloadThumbnail:(SavedPhoto *)photo {
    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailUrl]];
    
    AFImageRequestOperation *thumbnailOperation = [AFImageRequestOperation imageRequestOperationWithRequest:thumbnailRequest success:^(UIImage *image) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        [photo setThumbnail:image];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        [photo.syncDelegate didSyncPhoto:photo];
    }];
    
    [thumbnailOperation start];
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
            NSLog(@"Lat: %@ Long: %@", [photo latitude], [photo longitude]);
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
                [uploadedPhoto setPhotoId:[[JSON valueForKey:@"photo"] valueForKey:@"photo_id"]];
                [uploadedPhoto setFileUrl:[[JSON valueForKey:@"photo"] valueForKey:@"photo_original"]];
                [uploadedPhoto setThumbnailUrl:[[JSON valueForKey:@"photo"] valueForKey:@"photo_thumbnail_200x200"]];
                [uploadedPhoto setDidUpload:[NSNumber numberWithBool:YES]];
                if (![context save:&error]) {
                    NSLog(@"Error saving to Core Data");
                }
                
                if ([uploadedPhoto menuItemId]) {
                    [self tagPhoto:uploadedPhoto];
                }
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:[uploadedPhoto fileLocation] error:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Upload Failure");
        }];
        [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    } else {
        NSLog(@"Cannot upload photo; no user logged in");
    }
}

+ (void)tagPhoto:(SavedPhoto *)photo
{
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&entity_id=%@&access_token=%@", [[photo photoId] stringValue],
                                                                                                      [[photo menuItemId] stringValue], 
                                                                                                      [[User currentUser] accessToken]]; 
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:@"https://infoit.heroku.com/services/tag_photo"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        NSLog(@"Tag Photo Success!");
        NSLog(@"JSON: %@", JSON);
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        [photo setDidTag:[NSNumber numberWithBool:YES]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Error tagging, JSON: %@", JSON);
        NSLog(@"%@", error);
    }];
    [operation start];
}

@end
