//
//  MenuItem.m
//  MenuPics
//
//  Created by Christian Deonier on 5/12/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (MenuItem *)initWithJson:(id)json
{
    self = [super init];
    if (self) {
        [self setName:[json valueForKey:@"name"]];
        [self setDescription:[json valueForKey:@"description"]];
        [self setCategory:[json valueForKey:@"menu_category"]];
        [self setPrice:[json valueForKey:@"price"]];
        [self setLikeCount:[json valueForKey:@"like_count"]];
        [self setMenuType:[json valueForKey:@"menu_type"]];
        
        int photoCount = [[json valueForKey:@"photo_count"] intValue] + [[json valueForKey:@"external_photo_count"] intValue];
        [self setPhotoCount:[NSNumber numberWithInt:photoCount]];
        
        
        if ([[json objectForKey:@"profile_photo_type"] isEqualToString:@"ExternalPhoto"]) {
            [self setSmallThumbnailUrl:[json valueForKey:@"profile_photo_thumbnail"]];
            [self setThumbnailUrl:[json valueForKey:@"profile_photo_thumbnail"]];
        } else {
            [self setSmallThumbnailUrl:[json valueForKey:@"profile_photo_thumbnail_100x100"]];
            [self setThumbnailUrl:[json valueForKey:@"profile_photo_thumbnail_200x200"]];
        }
        
        [self setPhotoUrl:[json valueForKey:@"profile_photo"]];
        [self setEntityId:[json valueForKey:@"entity_id"]];
        
        BOOL isLiked = [[json valueForKeyPath:@"logged_in_user.liked"] boolValue];
        if (isLiked) {
            [self setIsLiked:YES];
        } else {
            [self setIsLiked:NO];
        }
    }
    
    return self;
}

@end
