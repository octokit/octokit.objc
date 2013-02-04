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
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (name != nil) userDict[@keypath(OCTUser.new, name)] = name;
	if (email != nil) userDict[@keypath(OCTUser.new, email)] = email;

	return [self modelWithDictionary:userDict];
}

+ (instancetype)userWithLogin:(NSString *)login password:(NSString *)password server:(OCTServer *)server {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (login != nil) userDict[@keypath(OCTUser.new, login)] = login;
	if (password != nil) userDict[@keypath(OCTUser.new, password)] = password;
	if (server.baseURL != nil) userDict[@keypath(OCTUser.new, baseURL)] = server.baseURL;

	return [self modelWithDictionary:userDict];
}

@end
