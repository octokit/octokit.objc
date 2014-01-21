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
// IDs, *or* if they were both created with +userWithLogin:server: and their
// logins and servers are equal.
@interface OCTUser : OCTEntity

// The username or email as entered by the user.
// In most cases rawLogin == login, however a single sign on login (LDAP, CAS)
// will have any character not in the set: [a-z0-9-] replaced with '-'.
@property (atomic, copy, readonly) NSString *rawLogin;

// Returns a user that has the given name and email address.
+ (instancetype)userWithName:(NSString *)name email:(NSString *)email;

// Returns a user with the given username and OCTServer instance.
+ (instancetype)userWithLogin:(NSString *)login server:(OCTServer *)server;

@end
