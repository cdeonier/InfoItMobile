//
//  User.m
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MenuPicsAPIClient.h"

@implementation User

@dynamic email, accessToken, username, userId, profilePhoto;

@synthesize syncDelegate;

+ (BOOL)isUserLoggedIn
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }

    if ([mutableFetchResults count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (User *)currentUser
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    assert([mutableFetchResults count] == 0 || [mutableFetchResults count] == 1); 
    
    if ([mutableFetchResults count] > 0) {
        return [mutableFetchResults objectAtIndex:0];
    } else {
        NSLog(@"No user logged in.");
        return nil;
    }
}

+ (void)signInUser:(NSString *)email withAccessToken:(NSString *)accessToken withUsername:(NSString *)username withUserId:(NSNumber *)userId
{
    [self signOutUser];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    User *newUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [newUser setEmail:email];
    [newUser setAccessToken:accessToken];
    [newUser setUsername:username];
    [newUser setUserId:userId];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
}

+ (void)signOutUser
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    if ([mutableFetchResults count] > 0) {
        [context deleteObject:[mutableFetchResults objectAtIndex:0]];

        if (![context save:&error]) {
            NSLog(@"Error deleting from Core Data");
        }
    }
    
}

+ (void)uploadProfilePhoto:(User *)user withImage:(UIImage *)profilePhoto
{
    NSLog(@"Uploading profile photo...");
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:[[User currentUser] accessToken] forKey:@"access_token"];
    
    NSData *imageData = UIImagePNGRepresentation(profilePhoto);
    
    NSString *path = @"/services/user/update_profile_photo";
    
    NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"PUT" path:path parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"profile_photo" fileName:@"profile_photo" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest 
    success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Upload Success");
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        [[User currentUser] setProfilePhoto:profilePhoto];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        [user.syncDelegate didSyncProfilePhoto];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Upload Failure");
    }];
    [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+ (void)downloadProfilePhoto:(User *)user withURL:(NSString *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        [user setProfilePhoto:image];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        [user.syncDelegate didSyncProfilePhoto];
    }];
    
    [operation start];
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
