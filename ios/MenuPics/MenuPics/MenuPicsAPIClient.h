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
typedef void (^ImageSuccessBlock)(UIImage *);

@class SavedPhoto;

@interface MenuPicsAPIClient : NSObject

//Fetches
+ (void)fetchNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success;
+ (void)fetchMenu:(NSNumber *)locationId success:(SuccessBlock)success;
+ (void)fetchMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success;
+ (void)fetchProfile:(NSNumber *)userId success:(SuccessBlock)success;

//Accounts
+ (void)signIn:(NSString *)user password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccount:(NSString *)user email:(NSString *)email password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)createAccountFromFacebook:(NSString *)accessToken success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)updateAccount:(NSString *)user email:(NSString *)email password:(NSString *)password updatedPassword:(NSString *)updatedPassword success:(SuccessBlock)success failure:(FailureBlock)failure;

//Photos
+ (void)uploadPhoto:(SavedPhoto *)photo;
+ (void)deletePhoto:(SavedPhoto *)photo success:(SuccessBlock)success;
+ (void)tagPhoto:(SavedPhoto *)photo success:(SuccessBlock)success;
+ (void)untagPhoto:(SavedPhoto *)photo success:(SuccessBlock)success;
+ (void)downloadPhotoThumbnail:(SavedPhoto *)photo success:(ImageSuccessBlock)success;

//User Actions
+ (void)favoriteMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success;
+ (void)unfavoriteMenuItem:(NSNumber *)menuItemId success:(SuccessBlock)success;
+ (void)votePhoto:(NSNumber *)photoId success:(SuccessBlock)success;
+ (void)unvotePhoto:(NSNumber *)photoId success:(SuccessBlock)success;

@end
