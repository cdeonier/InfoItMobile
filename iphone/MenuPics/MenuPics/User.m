//
//  User.m
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"

@implementation User

@dynamic email, accessToken, username;

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
        User *currentUser = [mutableFetchResults objectAtIndex:0];
        NSLog(@"Fetching currentUser... email:%@ access_token:%@ displayName: %@", currentUser.email, currentUser.accessToken, currentUser.username);
        return [mutableFetchResults objectAtIndex:0];
    } else {
        NSLog(@"No user logged in.");
        return nil;
    }
}

+ (void)signInUser:(NSString *)email withAccessToken:(NSString *)accessToken withUsername:(NSString *)username
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    User *newUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [newUser setEmail:email];
    [newUser setAccessToken:accessToken];
    [newUser setUsername:username];
    
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

@end
