//
//  JSON.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "JSONResponse.h"

#import "AppDelegate.h"

@implementation JSONResponse

@dynamic fetchDate, jsonResponse, viewController;

+ (id)recentJsonResponse:(UIViewController *)viewController
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JSONResponse" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewController == %@", viewControllerName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    if ([mutableFetchResults count] > 0) {
        JSONResponse *pastJsonResponse = [mutableFetchResults objectAtIndex:0];
        id JSON = [NSJSONSerialization JSONObjectWithData:[pastJsonResponse jsonResponse] options:NSJSONReadingAllowFragments error:&error];
        return JSON;
    } else {
        return nil;
    }
}

+ (NSDate *)recentJsonDate:(UIViewController *)viewController
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JSONResponse" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewController == %@", viewControllerName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    if ([mutableFetchResults count] > 0) {
        JSONResponse *pastJsonResponse = [mutableFetchResults objectAtIndex:0];
        return [pastJsonResponse fetchDate];
    } else {
        return nil;
    }
}

+ (void)saveJsonResponse:(UIViewController *)viewController withJsonResponse:(id)jsonResponse
{
    NSData *jsonAsData = [NSJSONSerialization dataWithJSONObject:jsonResponse options:0 error:nil];
    
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JSONResponse" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewController == %@", viewControllerName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    if ([mutableFetchResults count] > 0) {
        [context deleteObject:[mutableFetchResults objectAtIndex:0]];
    }
    
    JSONResponse *newJson = (JSONResponse *)[NSEntityDescription insertNewObjectForEntityForName:@"JSONResponse" inManagedObjectContext:context];
    [newJson setFetchDate:[NSDate date]];
    [newJson setJsonResponse:jsonAsData];
    [newJson setViewController:viewControllerName];
    
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
}

@end
