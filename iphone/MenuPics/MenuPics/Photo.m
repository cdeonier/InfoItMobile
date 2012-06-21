//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Photo.h"
#import "SavedPhoto.h"
#import "User.h"
#import "AppDelegate.h"
#import "MenuPicsAPIClient.h"

@implementation Photo

@synthesize fileName = _fileName;
@synthesize fileLocation = _fileLocation;
@synthesize smallThumbnail = _smallThumbnail;
@synthesize thumbnail = _thumbnail;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize isSelected = _isSelected;

+ (void)uploadPhotoAtLocation:(CLLocation *)location image:(UIImage *)image imageName:(NSString *)imageName photoDate:(NSDate *)date suggestedRestaurantId:(NSNumber *)suggestedRestaurantId
{
    NSLog(@"Uploading...");
    User *currentUser = [User currentUser];
    if (currentUser) {
        NSLog(@"We have a user");
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (location) {
            [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"photo[lat]"];
            [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"photo[lng]"];
        }
        
        if (suggestedRestaurantId)
            [mutableParameters setObject:suggestedRestaurantId forKey:@"photo[suggested_restaurant_id]"];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // e.g., set for mysql date strings
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSString *mysqlGMTString = [formatter stringFromDate:date];
        
        [mutableParameters setObject:mysqlGMTString forKey:@"photo[taken_at]"];
        NSLog(@"Paramters set");
        
        NSString *path = [NSString stringWithFormat:@"/services/photos?access_token=%@", [currentUser accessToken]];
        NSLog(@"Path: %@", path);

        NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8) name:@"photo[photo_attachment]" fileName:imageName mimeType:@"image/jpeg"];
        }];
        //NSLog([mutableURLRequest description]);
        
        AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest success:^(AFHTTPRequestOperation *operation, id JSON) {
            //NSLog([JSON description]);
            NSLog(@"Upload Success");
            NSLog(@"JSON: %@", JSON);
            
            if (JSON) {
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
                [request setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName = %@", imageName];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
                if (mutableFetchResults == nil) {
                    NSLog(@"Error fetching from Core Data");
                }
                
                //Assume that we can write to disk (eg, create the record for a saved photo) faster than server can respond to a photo upload, and we have a photo_id to process
                assert([mutableFetchResults count] > 0);
                assert([[JSON valueForKey:@"photo"] valueForKey:@"photo_id"] != nil);
                
                SavedPhoto *uploadedPhoto = [mutableFetchResults objectAtIndex:0];
                [uploadedPhoto setPhotoId:[JSON valueForKey:@"photo_id"]];
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
        NSLog(@"No user logged in");
    }
}

+ (void)savePhotos:(NSArray *)photoArray atLocation:(CLLocation *)location withRestaurantId:(NSNumber *)restaurantId
{
    NSIndexSet *indexSet = [photoArray indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [(Photo *)obj isSelected]; 
    }];
    NSArray *selectedPhotos = [photoArray objectsAtIndexes:indexSet];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
    
    NSDate *saveDate = [NSDate date];
    
    //Save to Core Data
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    for (Photo *photo in selectedPhotos) {
        SavedPhoto *savedPhoto = (SavedPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"SavedPhoto" inManagedObjectContext:context];
        [savedPhoto setFileName:[photo fileName]];
        [savedPhoto setFileLocation:[photo fileLocation]];
        [savedPhoto setSmallThumbnail:[photo smallThumbnail]];
        [savedPhoto setThumbnail:[photo thumbnail]];
        [savedPhoto setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
        [savedPhoto setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
        [savedPhoto setCreationDate:saveDate];
        [savedPhoto setDidUpload:[NSNumber numberWithBool:NO]];
        [savedPhoto setDidDelete:[NSNumber numberWithBool:NO]];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
    
    //Upload after we save to disk, because we'll modify saved record if successful
    for (Photo *photo in selectedPhotos) {
        [fileManager moveItemAtPath:[photo fileLocation] toPath:[photosDirectory stringByAppendingPathComponent:[photo fileName]] error:nil];
        [photo setFileLocation:[photosDirectory stringByAppendingPathComponent:[photo fileName]]];
        NSData *imageData = [NSData dataWithContentsOfFile:[photo fileLocation]];
        UIImage *image = [UIImage imageWithData:imageData];
        [Photo uploadPhotoAtLocation:location image:image imageName:[photo fileName] photoDate:saveDate suggestedRestaurantId:restaurantId];
    }
}

@end
