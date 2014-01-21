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

@interface OCTUser ()

@property (atomic, copy, readwrite) NSString *rawLogin;

@end

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
	if (login != nil) {
		userDict[@keypath(OCTUser.new, login)] = login;
		userDict[@keypath(OCTUser.new, rawLogin)] = login;
	}
	if (server.baseURL != nil) userDict[@keypath(OCTUser.new, baseURL)] = server.baseURL;

	return [self modelWithDictionary:userDict error:NULL];
}

#pragma mark MTLModel

- (void)mergeRawLoginFromModel:(OCTUser *)model {
	if (model.rawLogin != nil) {
		self.rawLogin = model.rawLogin;
	}
}

#pragma mark NSObject

- (NSUInteger)hash {
	if (self.objectID != nil) return self.objectID.hash ^ self.server.hash;

	return self.server.hash ^ self.login.hash;
}

- (BOOL)isEqual:(OCTUser *)user {
	if (self == user) return YES;
	if (![user isKindOfClass:self.class]) return NO;

	BOOL equalServers = [user.server isEqual:self.server];
	if (!equalServers) return NO;

	if (self.objectID != nil || user.objectID != nil) return [user.objectID isEqual:self.objectID];

	return [user.login isEqual:self.login];
}

@end
