//
//  JSON.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "JSONCachedResponse.h"

#import "MenuPicsDBClient.h"

@implementation JSONCachedResponse

@dynamic fetchDate, identifier, jsonResponse, viewController;

+ (id)recentJsonResponse:(UIViewController *)viewController withIdentifier:(NSNumber *)identifier
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    NSString *predicateString;
    if (identifier) {
        predicateString = [NSString stringWithFormat:@"(viewController == '%@') and (identifier == %d)", viewControllerName, [identifier intValue]];
    } else {
        predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    }
    
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONCachedResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        JSONCachedResponse *pastJsonResponse = [fetchResults objectAtIndex:0];
        id JSON = [NSJSONSerialization JSONObjectWithData:[pastJsonResponse jsonResponse] options:NSJSONReadingAllowFragments error:nil];
        return JSON;
    } else {
        return nil;
    }
}

+ (NSDate *)recentJsonDate:(UIViewController *)viewController withIdentifier:(NSNumber *)identifier
{
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    NSString *predicateString;
    if (identifier) {
        predicateString = [NSString stringWithFormat:@"(viewController == '%@') and (identifier == %d)", viewControllerName, [identifier intValue]];
    } else {
        predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    }
    
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONCachedResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        JSONCachedResponse *pastJsonResponse = [fetchResults objectAtIndex:0];
        return [pastJsonResponse fetchDate];
    } else {
        return nil;
    }
}

+ (void)saveJsonResponse:(UIViewController *)viewController withJsonResponse:(id)jsonResponse withIdentifier:(NSNumber *)identifier
{
    NSData *jsonAsData = [NSJSONSerialization dataWithJSONObject:jsonResponse options:0 error:nil];
    
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    
    NSString *predicateString;
    if (identifier) {
        predicateString = [NSString stringWithFormat:@"(viewController == '%@') and (identifier == %d)", viewControllerName, [identifier intValue]];
    } else {
        predicateString = [NSString stringWithFormat:@"viewController == '%@'", viewControllerName];
    }
    
    NSMutableArray *fetchResults = [MenuPicsDBClient fetchResultsFromDB:@"JSONCachedResponse" withPredicate:predicateString];
    
    if ([fetchResults count] > 0) {
        [MenuPicsDBClient deleteObject:[fetchResults objectAtIndex:0]];
    }
    
    JSONCachedResponse *newJson = (JSONCachedResponse *)[MenuPicsDBClient generateManagedObject:@"JSONCachedResponse"];
    [newJson setFetchDate:[NSDate date]];
    [newJson setIdentifier:identifier];
    [newJson setJsonResponse:jsonAsData];
    [newJson setViewController:viewControllerName];
    
    [MenuPicsDBClient saveContext];
}

@end
