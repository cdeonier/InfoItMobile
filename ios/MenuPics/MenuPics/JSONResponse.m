//
//  JSON.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "JSONResponse.h"

#import "MenuPicsDBClient.h"

@implementation JSONResponse

@dynamic fetchDate, jsonResponse, viewController;

+ (id)recentJsonResponse:(UIViewController *)viewController
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    NSString *predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        JSONResponse *pastJsonResponse = [fetchResults objectAtIndex:0];
        id JSON = [NSJSONSerialization JSONObjectWithData:[pastJsonResponse jsonResponse] options:NSJSONReadingAllowFragments error:nil];
        return JSON;
    } else {
        return nil;
    }
}

+ (NSDate *)recentJsonDate:(UIViewController *)viewController
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    NSString *predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        JSONResponse *pastJsonResponse = [fetchResults objectAtIndex:0];
        return [pastJsonResponse fetchDate];
    } else {
        return nil;
    }
}

+ (void)saveJsonResponse:(UIViewController *)viewController withJsonResponse:(id)jsonResponse
{
    NSData *jsonAsData = [NSJSONSerialization dataWithJSONObject:jsonResponse options:0 error:nil];
    
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    NSString *predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        [MenuPicsDBClient deleteObject:[fetchResults objectAtIndex:0]];
    }
    
    JSONResponse *newJson = (JSONResponse *)[MenuPicsDBClient generateManagedObject:@"JSONResponse"];
    [newJson setFetchDate:[NSDate date]];
    [newJson setJsonResponse:jsonAsData];
    [newJson setViewController:viewControllerName];
    
    [MenuPicsDBClient saveContext];
}

@end
