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
#import "User.h"

static NSString * const baseUrl = @"https://infoit-app.herokuapp.com/";

@implementation MenuPicsAPIClient

+ (void)getNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"services/geocode?latitude=%f&longitude=%f&type=nearby", location.coordinate.latitude, location.coordinate.longitude];
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

+ (void)getMenu:(NSNumber *)locationId success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"services/%d", [locationId intValue]];
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

+ (void)signIn:(NSString *)user password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *endpoint = @"services/tokens";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"user=%@&password=%@", user, password];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)createAccount:(NSString *)user email:(NSString *)email password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *endpoint = @"users.json";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"user[email]=%@&user[username]=%@&user[password]=%@&user[password_confirmation]=%@", email, user, password, password];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)createAccountFromFacebook:(NSString *)accessToken success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *endpoint = @"services/facebook/create";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"fb_access_token=%@", accessToken];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)updateAccount:(NSString *)user email:(NSString *)email password:(NSString *)password updatedPassword:(NSString *)updatedPassword success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *endpoint;
    if ([[User currentUser] isFacebookOnly]) {
        endpoint = @"services/facebook/update_user";
    } else {
        endpoint = @"services/update_user";
    }
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"user[email]=%@&user[username]=%@", email, user];
    
    if ([[User currentUser] isFacebookOnly]) {
        requestString = [requestString stringByAppendingFormat:@"&access_token=%@", [[User currentUser] accessToken]];
    } else {
        requestString = [requestString stringByAppendingFormat:@"&access_token=%@&current_password=%@", [[User currentUser] accessToken], password];
    }
    
    if (updatedPassword.length > 0) {
        requestString = [requestString stringByAppendingFormat:@"&user[password]=%@&user[password_confirmation]=%@", updatedPassword, updatedPassword];
    }
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
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
