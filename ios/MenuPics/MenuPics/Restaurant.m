//
//  Restaurant.m
//  MenuPics
//
//  Created by Christian Deonier on 5/17/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (Restaurant *)initWithJson:(id)json
{
    self = [super init];
    if (self) {
        id entityJson = [json valueForKey:@"entity"];
        id placeDetailsJson = [entityJson valueForKey:@"place_details"];
        id addressJson = [placeDetailsJson valueForKey:@"address"];
        id contactJson = [placeDetailsJson valueForKey:@"contact_information"];
        
        [self setEntityId:[entityJson valueForKey:@"id"]];
        [self setName:[entityJson valueForKey:@"name"]];
        [self setDescription:[entityJson valueForKey:@"description"]];
        [self setProfilePhotoUrl:[entityJson valueForKey:@"profile_photo"]];
        [self setStreetOne:[addressJson valueForKey:@"street_address_one"]];
        [self setStreetTwo:[addressJson valueForKey:@"street_address_two"]];
        [self setCity:[addressJson valueForKey:@"city"]];
        [self setState:[addressJson valueForKey:@"state"]];
        [self setZipCode:[addressJson valueForKey:@"zip_code"]];
        [self setPhone:[contactJson valueForKey:@"phone"]];
    }
    
    return self;
}

@end
