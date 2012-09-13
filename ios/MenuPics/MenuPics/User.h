//
//  User.h
//  MenuPics
//
//  Created by Christian Deonier on 9/9/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ProfileImageToDataTransformer : NSValueTransformer

@end

@interface User : NSManagedObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) NSString *loginType;

+ (User *)currentUser;
+ (void)signInUser:(NSString *)email accessToken:(NSString *)accessToken username:(NSString *)username userId:(NSNumber *)userId loginType:(NSString *)loginType;
+ (void)signOutUser;

- (BOOL)isFacebookOnly;

@end
