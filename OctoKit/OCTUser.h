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

// Returns a user that has the given name and email address.
+ (instancetype)userWithName:(NSString *)name email:(NSString *)email;

// Returns a user with the given username and OCTServer instance.
+ (instancetype)userWithLogin:(NSString *)login server:(OCTServer *)server;

@end
