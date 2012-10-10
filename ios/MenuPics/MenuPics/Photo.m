//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 9/16/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "Photo.h"

#import "MenuItem.h"
#import "SavedPhoto.h"
#import "User.h"

@implementation Photo

+ (NSMutableArray *)menuItemPhotosFromJson:(id)json
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (id photoEntry in [[json valueForKey:@"entity"] valueForKey:@"photos"]) {
        id photoJson = [photoEntry valueForKey:@"photo"];
        Photo *menuItemPhoto = [[Photo alloc] init];
        [menuItemPhoto setPhotoId:[photoJson valueForKey:@"photo_id"]];
        [menuItemPhoto setPhotoUrl:[photoJson valueForKey:@"photo_original"]];
        [menuItemPhoto setSmallThumbnailUrl:[photoJson valueForKey:@"photo_thumbnail_100x100"]];
        [menuItemPhoto setThumbnailUrl:[photoJson valueForKey:@"photo_thumbnail_200x200"]];
        [menuItemPhoto setAuthorId:[photoJson valueForKey:@"photo_author_id"]];
        [menuItemPhoto setAuthor:[photoJson valueForKey:@"photo_author"]];
        [menuItemPhoto setPoints:[photoJson valueForKey:@"photo_points"]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *creationDateWithLetters = [photoJson valueForKey:@"photo_taken_date"];
        NSString *creationDate = [[creationDateWithLetters componentsSeparatedByCharactersInSet:[NSCharacterSet letterCharacterSet]] componentsJoinedByString:@" "];
        [menuItemPhoto setCreationDate:[formatter dateFromString:creationDate]];
        
        if ([User currentUser]) {
            [menuItemPhoto setVotedForPhoto:[[[photoJson valueForKey:@"logged_in_user"] valueForKey:@"photo_voted"] boolValue]];
        }
        
        [photos addObject:menuItemPhoto];
    }
    
    return photos;
}

+ (NSMutableArray *)userPhotosFromJson:(id)json
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (id photoEntry in [[json valueForKey:@"user"] valueForKey:@"photos"]) {
        id photoJson = [photoEntry valueForKey:@"photo"];
        NSString *photoFileName = [photoJson valueForKey:@"photo_filename"];
        
        if ([photoFileName isEqualToString:@"profile_photo"]) {
            continue;
        }
        
        Photo *userPhoto = [[Photo alloc] init];
        [userPhoto setPhotoId:[photoJson valueForKey:@"photo_id"]];
        [userPhoto setFileName:[photoJson valueForKey:@"photo_filename"]];
        [userPhoto setPhotoUrl:[photoJson valueForKey:@"photo_original"]];
        [userPhoto setSmallThumbnailUrl:[photoJson valueForKey:@"photo_thumbnail_100x100"]];
        [userPhoto setThumbnailUrl:[photoJson valueForKey:@"photo_thumbnail_200x200"]];
        [userPhoto setPoints:[[photoJson valueForKey:@"tagged_info"] valueForKey:@"photo_points"]];
        [userPhoto setMenuItemId:[[photoJson valueForKey:@"tagged_info"] valueForKey:@"menu_item_id"]];
        [userPhoto setMenuItemName:[[photoJson valueForKey:@"tagged_info"] valueForKey:@"menu_item_name"]];
        [userPhoto setRestaurantId:[[photoJson valueForKey:@"tagged_info"] valueForKey:@"restaurant_id"]];
        [userPhoto setRestaurantName:[[photoJson valueForKey:@"tagged_info"] valueForKey:@"restaurant_name"]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *creationDateWithLetters = [photoJson valueForKey:@"photo_taken_date"];
        NSString *creationDate = [[creationDateWithLetters componentsSeparatedByCharactersInSet:[NSCharacterSet letterCharacterSet]] componentsJoinedByString:@" "];
        [userPhoto setCreationDate:[formatter dateFromString:creationDate]];
        
        [photos addObject:userPhoto];
    }
    
    return photos;
}

+ (Photo *)didTakeNewPhoto:(MenuItem *)menuItem image:(UIImage *)image thumbnail:(UIImage *)thumbnail
{
    Photo *photo = [[Photo alloc] init];
    
    [photo setMenuItemId:menuItem.entityId];
    [photo setMenuItemName:menuItem.name];
    [photo setRestaurantId:menuItem.restaurantId];
    [photo setRestaurantName:menuItem.restaurantName];
    [photo setPoints:[NSNumber numberWithInt:1]];
    [photo setVotedForPhoto:YES];
    [photo setCreationDate:[NSDate date]];
    
    [photo setMenuItem:menuItem];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *takePhotosDirectory = [docsDir stringByAppendingPathComponent:@"takePhotos"];
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    NSString *imageFileName = [NSString stringWithFormat:@"%f", currentTime];
    imageFileName = [imageFileName stringByReplacingOccurrencesOfString:@"." withString:@""];
    imageFileName = [imageFileName stringByAppendingString:@".jpg"];
    NSString *filePath = [takePhotosDirectory stringByAppendingPathComponent:imageFileName];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:filePath atomically:YES];
    
    [photo setFileName:imageFileName];
    [photo setFileLocation:filePath];
    [photo setThumbnail:thumbnail];
    
    [menuItem setPhotoFileLocation:filePath];
    
    User *author = [User currentUser];
    [photo setAuthor:author.username];
    [photo setAuthorId:author.userId];
    
    [SavedPhoto uploadPhoto:photo];
    
    return photo;
}

@end
