//
//  OCTUser.m
//  OctoKit
//
//  Created by Joe Ricioppo on 7/28/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTUser.h"
#import "OCTServer.h"
#import "EXTKeyPathCoding.h"
#import "OCTObject+Private.h"

@implementation OCTUser

#pragma mark Lifecycle

+ (instancetype)userWithName:(NSString *)name email:(NSString *)email {
	OCTUser *user = [[self alloc] init];
	user.name = name;
	user.email = email;
	return user;
}

+ (instancetype)userWithLogin:(NSString *)login password:(NSString *)password server:(OCTServer *)server {
	OCTUser *user = [[self alloc] init];
	user.login = login;
	user.password = password;
	user.baseURL = server.baseURL;
	return user;
}

@end
