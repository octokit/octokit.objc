//
//  OCTUser.h
//  OctoKit
//
//  Created by Joe Ricioppo on 7/28/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTEntity.h"

// A GitHub user.
//
// Users are equal if they come from the same server and have matching object
// IDs, *or* if they were both created with +userWithRawLogin:server: and their
// `rawLogin` and `server` properties are equal.
@interface OCTUser : OCTEntity

// The username or email entered by the user.
//
// In most cases, this will be the same as the `login`. However, single sign-on
// systems like LDAP and CAS may have different username requirements than
// GitHub, meaning that the `login` may not work directly for authentication,
// or the `rawLogin` may not work directly with the API.
@property (nonatomic, copy, readonly) NSString *rawLogin;

// Returns a user that has the given name and email address.
+ (instancetype)userWithName:(NSString *)name email:(NSString *)email;

// Returns a user with the given username and OCTServer instance.
+ (instancetype)userWithRawLogin:(NSString *)rawLogin server:(OCTServer *)server;

@end
