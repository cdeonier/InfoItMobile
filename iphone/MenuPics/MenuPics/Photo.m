//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Photo.h"
#import "SavedPhoto.h"
#import "AppDelegate.h"
#import "MenuPicsAPIClient.h"

@implementation Photo

@synthesize fileName = _fileName;
@synthesize fileLocation = _fileLocation;
@synthesize thumbnail = _thumbnail;
@synthesize isSelected = _isSelected;

+ (void)uploadPhotoAtLocation:(CLLocation *)location
                        image:(UIImage *)image
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"photo[lat]"];
    [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"photo[lng]"];
    
    NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/services/photos?access_token=72d41492785ebe68fc9e46d5510dda17a21e8c2b46c27bf7535324b3e72d6401" parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8) name:@"photo[photo_attachment]" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    }];
    //NSLog([mutableURLRequest description]);
    
    AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog([JSON description]);
        NSLog(@"Upload Success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Upload Failure");
    }];
    [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+ (void)savePhotos:(NSArray *)photoArray creationDate:(NSDate *)date creationLocation:(CLLocation *)location
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];

    for (Photo *photo in photoArray) {
        SavedPhoto *savedPhoto = (SavedPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"SavedPhoto" inManagedObjectContext:context];
        [savedPhoto setFileName:[photo fileName]];
        [savedPhoto setFileLocation:[photo fileLocation]];
        [savedPhoto setThumbnail:[photo thumbnail]];
        [savedPhoto setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
        [savedPhoto setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
        [savedPhoto setCreationDate:date];
        [savedPhoto setIsUploaded:[NSNumber numberWithBool:NO]];
    }
    
    NSError *error = nil;
    if (![[delegate managedObjectContext] save:&error]) {
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
