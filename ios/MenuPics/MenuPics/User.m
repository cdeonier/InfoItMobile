//
//  User.m
//  MenuPics
//
//  Created by Christian Deonier on 9/9/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "User.h"    

#import "MenuPicsDBClient.h"

@implementation User

@dynamic email, accessToken, username, userId, profilePhoto, loginType;

+ (User *)currentUser
{
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"User" withPredicate:nil];
    
    assert([fetchResults count] == 0 || [fetchResults count] == 1);
    
    if ([fetchResults count] > 0) {
        return [fetchResults objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (void)signInUser:(NSString *)email accessToken:(NSString *)accessToken username:(NSString *)username userId:(NSNumber *)userId loginType:(NSString *)loginType
{
    User *user = (User *)[MenuPicsDBClient generateManagedObject:@"User"];
    [user setEmail:email];
    [user setAccessToken:accessToken];
    [user setUsername:username];
    [user setUserId:userId];
    [user setLoginType:loginType];
    [MenuPicsDBClient saveContext];
}

+ (void)signOutUser
{
    User *currentUser = [self currentUser];
    
    if (currentUser) {
        [MenuPicsDBClient deleteObject:currentUser];
    }
    
    [MenuPicsDBClient saveContext];
}

- (BOOL)isFacebookOnly {
    if ([[self loginType] isEqualToString:@"FACEBOOK"]) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation ProfileImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end

