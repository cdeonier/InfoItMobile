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

+ (void)uploadPhotoAtLocation:(CLLocation *)location image:(UIImage *)image photoDate:(NSDate *)date
{
    User *currentUser = [User currentUser];
    if (currentUser) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"photo[lat]"];
        [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"photo[lng]"];
        [mutableParameters setObject:[NSNumber numberWithInt:1] forKey:@"photo[suggested_restaurant_id]"];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // e.g., set for mysql date strings
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSString *mysqlGMTString = [formatter stringFromDate:date];
        
        [mutableParameters setObject:mysqlGMTString forKey:@"photo[taken_at]"];
        
        NSString *path = [NSString stringWithFormat:@"/services/photos?access_token=%@", [currentUser accessToken]];
        NSLog(@"Path: %@", path);
        
        NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8) name:@"photo[photo_attachment]" fileName:@"image.jpg" mimeType:@"image/jpeg"];
        }];
        //NSLog([mutableURLRequest description]);
        
        AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest success:^(AFHTTPRequestOperation *operation, id JSON) {
            //NSLog([JSON description]);
            NSLog(@"Upload Success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Upload Failure");
            NSLog([error description]);
        }];
        [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    }
}

+ (void)savePhotos:(NSArray *)photoArray creationDate:(NSDate *)date creationLocation:(CLLocation *)location
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];

    for (Photo *photo in photoArray) {
        SavedPhoto *savedPhoto = (SavedPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"SavedPhoto" inManagedObjectContext:context];
        [savedPhoto setFileName:[photo fileName]];
        [savedPhoto setFileLocation:[photo fileLocation]];
        [savedPhoto setSmallThumbnail:[photo smallThumbnail]];
        [savedPhoto setThumbnail:[photo thumbnail]];
        [savedPhoto setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
        [savedPhoto setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
        [savedPhoto setCreationDate:date];
        [savedPhoto setDidUpload:[NSNumber numberWithBool:NO]];
        [savedPhoto setDidDelete:[NSNumber numberWithBool:NO]];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    NSLog(@"Total saved photos in Core Data: %i", [mutableFetchResults count]);
}

@end