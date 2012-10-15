//
//  MenuPicsDBClient.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuPicsDBClient : NSObject

+ (NSManagedObjectContext *)getMainContext;
+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicateString;
+ (NSManagedObject *)generateManagedObject:(NSString *)entityName;
+ (void)deleteObject:(NSManagedObject *)managedObject;
+ (void)saveContext;

//For Async threads
+ (NSManagedObjectContext *)generateBackgroundContext;
+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicate context:(NSManagedObjectContext *)context;
+ (void)deleteObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context;
+ (void)saveContext:(NSManagedObjectContext *)context;

@end
