//
//  MenuPicsDBClient.m
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuPicsDBClient.h"

#import "AppDelegate.h"

@implementation MenuPicsDBClient

+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicateString
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    return mutableFetchResults;
}

+ (NSManagedObject *)generateManagedObject:(NSString *)entityName
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSManagedObject *newObject = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    
    return newObject;
}

+ (void)deleteObject:(NSManagedObject *)managedObject
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    [context deleteObject:managedObject];
}

+ (void)saveContext
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
}

@end
