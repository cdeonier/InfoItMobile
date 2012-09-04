//
//  JSON.h
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface JSONResponse : NSManagedObject

@property (nonatomic, strong) NSDate *fetchDate;
@property (nonatomic, strong) NSData *jsonResponse;
@property (nonatomic, strong) NSString *viewController;

+ (JSONResponse *)recentJsonResponse:(UIViewController *)viewController;
+ (NSDate *)recentJsonDate:(UIViewController *)viewController;

+ (void)saveJsonResponse:(UIViewController *)viewController withJsonResponse:(id)jsonResponse;

@end