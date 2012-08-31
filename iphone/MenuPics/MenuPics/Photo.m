//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 6/28/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Photo.h"
#import "SavedPhoto.h"
#import "User.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@implementation Photo

@synthesize photoId = _photoId;
@synthesize photoUrl = _photoUrl;
@synthesize fileName = _fileName;
@synthesize fileLocation = _fileLocation;
@synthesize smallThumbnailUrl = _smallThumbnailUrl;
@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize thumbnail = _thumbnail;
@synthesize authorId = _authorId;
@synthesize author = _photoAuthor;
@synthesize points = _points;
@synthesize votedForPhoto = _votedForPhoto;
@synthesize menuItemName = _menuItemName;
@synthesize menuItemId = _menuItemId;
@synthesize restaurantName = _restaurantName;
@synthesize restaurantId = _restaurantId;

- (id)initWithSavedPhoto:(SavedPhoto *)savedPhoto
{
    [self setPhotoId:[savedPhoto photoId]];
    [self setPhotoUrl:[savedPhoto fileUrl]];
    [self setFileName:[savedPhoto fileName]];
    [self setFileLocation:[savedPhoto fileLocation]];
    [self setThumbnailUrl:[savedPhoto thumbnailUrl]];
    [self setThumbnail:[savedPhoto thumbnail]];
    [self setAuthorId:[[User currentUser] userId]];
    [self setAuthor:[[User currentUser] username]];
    [self setPoints:[savedPhoto points]];
    [self setMenuItemId:[savedPhoto menuItemId]];
    [self setMenuItemName:[savedPhoto menuItemName]];
    [self setRestaurantId:[savedPhoto restaurantId]];
    [self setRestaurantName:[savedPhoto restaurantName]];
    
    return self;
}

+ (void)tagPhoto:(Photo *)photo withMenuItemId:(NSInteger)menuItemId
{
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&entity_id=%d&access_token=%@", [[photo photoId] stringValue],
                               menuItemId, 
                               [[User currentUser] accessToken]]; 
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/tag_photo"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                         {
                                             NSLog(@"Tag Photo Success!");
                                             NSLog(@"JSON: %@", JSON);
                                         } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"Error tagging, JSON: %@", JSON);
                                             NSLog(@"%@", error);
                                         }];
    [operation start];
}

+ (void)untagPhoto:(Photo *)photo
{
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [[photo photoId] stringValue], [[User currentUser] accessToken]]; 
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/untag_photo"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                         {
                                             NSLog(@"Untag Photo Success!");
                                             NSLog(@"JSON: %@", JSON);
                                         } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"Error untagging, JSON: %@", JSON);
                                             NSLog(@"%@", error);
                                         }];
    [operation start];
}

+ (void)deletePhoto:(Photo *)photo
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error = nil;

    SavedPhoto *savedPhoto = [Photo savedPhotoWithPhotoId:[photo photoId]];
    [savedPhoto setDidDelete:[NSNumber numberWithBool:YES]];
    
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [[photo photoId] stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/delete_photo"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             [context deleteObject:savedPhoto];
                                             NSError *deleteError = nil;
                                             if (![context save:&deleteError]) {
                                                 NSLog(@"Error saving to Core Data");
                                             }
                                             
                                             NSLog(@"Delete Photo Success!");
                                             NSLog(@"JSON: %@", JSON);
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"Error delete photo, JSON: %@", JSON);
                                             NSLog(@"%@", error);
                                         }];
    [operation start];
}

+ (SavedPhoto *)savedPhotoWithPhotoId:(NSNumber *)photoId
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *coreDataRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [coreDataRequest setEntity:entity];
    
    NSString *predicateString = [NSString stringWithFormat:@"photoId == %d", [photoId intValue]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [coreDataRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:coreDataRequest error:&error] mutableCopy];
    
    SavedPhoto *savedPhoto = [mutableFetchResults objectAtIndex:0];
    
    return savedPhoto;
}

@end
