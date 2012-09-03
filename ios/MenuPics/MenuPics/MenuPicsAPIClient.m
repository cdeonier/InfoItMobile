//
//  MenuPicsAPIClient.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuPicsAPIClient.h"

#import "AFNetworking.h"
#import "SVProgressHUD.h"

static NSString * const baseUrl = @"https://infoit-app.herokuapp.com/";

@implementation MenuPicsAPIClient

+ (void)getNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"services/geocode?latitude=%+.6f&longitude=%+.6f&type=nearby", location.coordinate.latitude, location.coordinate.longitude];
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (FailureBlock)getFailureBlock
{
    void (^failureBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
    failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
        NSLog(@"%@", [error description]);
    };
    return failureBlock;
}

@end
