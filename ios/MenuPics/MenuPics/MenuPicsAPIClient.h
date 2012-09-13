//
//  MenuPicsAPIClient.h
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^SuccessBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
typedef void (^FailureBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);

@interface MenuPicsAPIClient : NSObject

+ (void)getNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success;
+ (void)getMenu:(NSNumber *)locationId success:(SuccessBlock)success;

//Accounts
+ (void)signIn:(NSString *)user password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccount:(NSString *)user email:(NSString *)email password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccountFromFacebook:(NSString *)accessToken success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)updateAccount:(NSString *)user email:(NSString *)email password:(NSString *)password updatedPassword:(NSString *)updatedPassword success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
