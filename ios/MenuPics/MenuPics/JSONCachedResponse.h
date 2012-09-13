//
//  JSON.h
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface JSONCachedResponse : NSManagedObject

@property (nonatomic, strong) NSDate *fetchDate;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSData *jsonResponse;
@property (nonatomic, strong) NSString *viewController;

+ (JSONCachedResponse *)recentJsonResponse:(UIViewController *)viewController withIdentifier:(NSNumber *)identifier;
+ (NSDate *)recentJsonDate:(UIViewController *)viewController withIdentifier:(NSNumber *)identifier;

+ (void)saveJsonResponse:(UIViewController *)viewController withJsonResponse:(id)jsonResponse withIdentifier:(NSNumber *)identifier;

@end