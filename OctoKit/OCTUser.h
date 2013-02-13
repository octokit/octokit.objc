//
//  OCTUser.h
//  OctoKit
//
//  Created by Joe Ricioppo on 7/28/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTEntity.h"

// A GitHub user.
@interface OCTUser : OCTEntity

// The user's password.
//
// TODO: Keeping this in memory as plaintext is a bad idea. We shouldn't load it
// from the credential storage unless we need it.
@property (atomic, copy) NSString *password;

@property (nonatomic, copy) NSString *location;

@property (nonatomic, copy) NSDate *createdAt;

@property (nonatomic, copy) NSNumber *followers;

@property (nonatomic, copy) NSNumber *following;

// Returns a user that has the given name and email address.
+ (instancetype)userWithName:(NSString *)name email:(NSString *)email;

// Returns a user with the given username, password, and OCTServer instance.
+ (instancetype)userWithLogin:(NSString *)login password:(NSString *)password server:(OCTServer *)server;

@end
