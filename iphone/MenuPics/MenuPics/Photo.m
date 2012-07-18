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
@synthesize restaurantName = _restaurantName;

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

@end
