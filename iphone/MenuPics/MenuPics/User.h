//
//  User.h
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol SyncUserDelegate <NSObject>

- (void)didSyncProfilePhoto;

@end

@interface ProfileImageToDataTransformer : NSValueTransformer {
}
@end

@interface User : NSManagedObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) NSString *loginType;

@property (nonatomic, strong) id<SyncUserDelegate> syncDelegate;

+ (BOOL)isUserLoggedIn;
+ (User *)currentUser;
+ (void)signInUser:(NSString *)email withAccessToken:(NSString *)accessToken withUsername:(NSString *)username withUserId:(NSNumber *)userId withLoginType:(NSString *)loginType;
+ (void)signOutUser;
+ (void)uploadProfilePhoto:(User *)user withImage:(UIImage *)profilePhoto;
+ (void)downloadProfilePhoto:(User *)user withURL:(NSString *)url;

- (BOOL)isFacebookOnly;

@end
