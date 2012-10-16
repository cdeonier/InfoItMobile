//
//  MenuPicsAPIClient.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuPicsAPIClient.h"

#import "AFNetworking.h"
#import "MenuPicsDBClient.h"
#import "SavedPhoto.h"
#import "SVProgressHUD.h"
#import "User.h"

static NSString * const baseUrl = @"https://infoit-app.herokuapp.com";

@implementation MenuPicsAPIClient

+ (void)fetchNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"/services/geocode?latitude=%f&longitude=%f&type=nearby", location.coordinate.latitude, location.coordinate.longitude];
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

+ (void)fetchMenu:(NSNumber *)locationId success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"/services/%d", [locationId intValue]];
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", [currentUser accessToken]]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)fetchMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"/services/%d", [menuItemId intValue]];
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", [currentUser accessToken]]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)fetchProfile:(NSNumber *)userId success:(SuccessBlock)success
{
    NSString *endpoint = [NSString stringWithFormat:@"/services/user_profile?access_token=%@&user_id=%@", [[User currentUser] accessToken], userId.stringValue];
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
    NSString *endpoint = @"/services/tokens";
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
    NSString *endpoint = @"/users.json";
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
    NSString *endpoint = @"/services/facebook/create";
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
        endpoint = @"/services/facebook/update_user";
    } else {
        endpoint = @"/services/update_user";
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

+ (void)uploadPhoto:(SavedPhoto *)photo success:(UploadSuccessBlock)success failure:(UploadFailureBlock)failure
{
    NSString *endpoint = [NSString stringWithFormat:@"/services/photos?access_token=%@", [[User currentUser] accessToken]];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:[photo latitude] forKey:@"photo[lat]"];
    [mutableParameters setObject:[photo longitude] forKey:@"photo[lng]"];
    
    if ([photo restaurantId]) {
        [mutableParameters setObject:[photo restaurantId] forKey:@"photo[suggested_restaurant_id]"];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // e.g., set for mysql date strings
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *mysqlGMTString = [formatter stringFromDate:[photo creationDate]];
    [mutableParameters setObject:mysqlGMTString forKey:@"photo[taken_at]"];
    
    NSData *imageData = [NSData dataWithContentsOfFile:[photo fileLocation]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    
    NSMutableURLRequest *mutableURLRequest = [httpClient multipartFormRequestWithMethod:@"POST" path:endpoint parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo[photo_attachment]" fileName:[photo fileName] mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:mutableURLRequest];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
}

+ (void)deletePhoto:(SavedPhoto *)photo success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/delete_photo";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [photo.photoId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)tagPhoto:(SavedPhoto *)photo success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/tag_photo";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&entity_id=%d&access_token=%@", [photo.photoId stringValue], [photo.menuItemId intValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)untagPhoto:(SavedPhoto *)photo success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/untag_photo";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [photo.photoId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)downloadPhotoThumbnail:(SavedPhoto *)photo success:(ImageSuccessBlock)success
{
    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailUrl]];
    
    AFImageRequestOperation *thumbnailOperation = [AFImageRequestOperation imageRequestOperationWithRequest:thumbnailRequest success:success];
    
    [thumbnailOperation start];
}

+ (void)favoriteMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/like";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [menuItemId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)unfavoriteMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/unlike";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [menuItemId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)votePhoto:(NSNumber *)photoId success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/photo_vote";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [photoId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)unvotePhoto:(NSNumber *)photoId success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/photo_remove_vote";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    NSString *requestString = [NSString stringWithFormat:@"photo_id=%@&access_token=%@", [photoId stringValue], [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    FailureBlock failure = [self getFailureBlock];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [operation start];
}

+ (void)sendFeedback:(NSString *)email message:(NSString *)message success:(SuccessBlock)success
{
    NSString *endpoint = @"/services/feedbacks";
    NSString *urlString = [baseUrl stringByAppendingString:endpoint];
    
    User *currentUser = [User currentUser];
    NSString *requestString;
    if (currentUser) {
        requestString = [NSString stringWithFormat:@"access_token=%@&message=%@", [currentUser accessToken], message];
    } else {
        requestString = [NSString stringWithFormat:@"message=%@&email=%@", message, email];
    }
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
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
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(errorFinished) userInfo:nil repeats:NO];
        NSLog(@"%@", [error description]);
    };
    return failureBlock;
}

+ (void)errorFinished
{
    [SVProgressHUD dismiss];
}

@end
