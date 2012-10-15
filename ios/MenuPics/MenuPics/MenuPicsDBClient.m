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

+ (NSManagedObjectContext *)getMainContext
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    return context;
}

+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicateString
{
    NSManagedObjectContext *context = [self getMainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    if (predicateString) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    return mutableFetchResults;
}

+ (NSManagedObject *)generateManagedObject:(NSString *)entityName
{
    NSManagedObjectContext *context = [self getMainContext];
    
    NSManagedObject *newObject = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    
    return newObject;
}

+ (void)deleteObject:(NSManagedObject *)managedObject
{
    NSManagedObjectContext *context = [self getMainContext];
    
    [context deleteObject:managedObject];
}

+ (void)saveContext
{
    NSManagedObjectContext *context = [self getMainContext];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
}

+ (NSManagedObjectContext *)generateBackgroundContext
{
    NSManagedObjectContext *mainContext = [self getMainContext];
    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] init];
    [backgroundContext setPersistentStoreCoordinator:[mainContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:backgroundContext];
    
    return backgroundContext;
}

+ (void)removeBackgroundContext:(NSManagedObjectContext *)context
{
    context = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicateString context:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    if (predicateString) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching JSON from Core Data");
    }
    
    return mutableFetchResults;
}

+ (void)deleteObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context
{
    [context deleteObject:managedObject];
}

+ (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data (Background)");
    }
}

- (void)backgroundContextDidSave:(NSNotification *)notification {
    NSManagedObjectContext *mainContext = [MenuPicsDBClient getMainContext];
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}

@end
