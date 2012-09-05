//
//  MenuPicsDBClient.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuPicsDBClient : NSObject

+ (NSMutableArray *)fetchResultsFromDB:(NSString *)entityName withPredicate:(NSString *)predicate;
+ (NSManagedObject *)generateManagedObject:(NSString *)entityName;
+ (void)deleteObject:(NSManagedObject *)managedObject;
+ (void)saveContext;

@end
