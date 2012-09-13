//
//  Restaurant.m
//  MenuPics
//
//  Created by Christian Deonier on 5/17/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize entityId = _entityId;
@synthesize name = _name;
@synthesize description = _description;
@synthesize profilePhotoUrl = _profilePhotoUrl;
@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize streetOne = _streetOne;
@synthesize streetTwo = _streetTwo;
@synthesize city = _city;
@synthesize state = _state;
@synthesize zipCode = _zipCode;
@synthesize email = _email;
@synthesize phone = _phone;
@synthesize website = _website;

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
