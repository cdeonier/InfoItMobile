//
//  User.h
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *userId;

+ (BOOL)isUserLoggedIn;
+ (User *)currentUser;
+ (void)signInUser:(NSString *)email withAccessToken:(NSString *)accessToken withUsername:(NSString *)username withUserId:(NSNumber *)userId;
+ (void)signOutUser;

@end
