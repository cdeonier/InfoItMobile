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

+ (void)fetchNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success;
+ (void)fetchMenu:(NSNumber *)locationId success:(SuccessBlock)success;
+ (void)fetchMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success;

//Accounts
+ (void)signIn:(NSString *)user password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccount:(NSString *)user email:(NSString *)email password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccountFromFacebook:(NSString *)accessToken success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)updateAccount:(NSString *)user email:(NSString *)email password:(NSString *)password updatedPassword:(NSString *)updatedPassword success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
