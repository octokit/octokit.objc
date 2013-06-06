//
//  OCTUser.m
//  OctoKit
//
//  Created by Joe Ricioppo on 7/28/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTUser.h"
#import "OCTServer.h"
#import <ReactiveCocoa/EXTKeyPathCoding.h>
#import "OCTObject+Private.h"

@implementation OCTUser

#pragma mark Lifecycle

+ (instancetype)userWithName:(NSString *)name email:(NSString *)email {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (name != nil) userDict[@keypath(OCTUser.new, name)] = name;
	if (email != nil) userDict[@keypath(OCTUser.new, email)] = email;

	return [self modelWithDictionary:userDict error:NULL];
}

+ (instancetype)userWithLogin:(NSString *)login server:(OCTServer *)server {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (login != nil) userDict[@keypath(OCTUser.new, login)] = login;
	if (server.baseURL != nil) userDict[@keypath(OCTUser.new, baseURL)] = server.baseURL;

	return [self modelWithDictionary:userDict error:NULL];
}

#pragma mark MTLModel

- (void)mergeLoginFromModel:(MTLModel *)model {
	// Don't ever replace the login property, as this could be different
	// to the login property returned by the API (eg. LDAP logins
	// have any characters in [a-z0-9-] replaced with '-' for their GitHub
	// Enterprise 'login').
}

@end
