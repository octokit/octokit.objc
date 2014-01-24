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

@implementation OCTUser {
	NSString *_rawLogin;
}

#pragma mark Lifecycle

+ (instancetype)userWithName:(NSString *)name email:(NSString *)email {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (name != nil) userDict[@keypath(OCTUser.new, name)] = name;
	if (email != nil) userDict[@keypath(OCTUser.new, email)] = email;

	return [self modelWithDictionary:userDict error:NULL];
}

+ (instancetype)userWithRawLogin:(NSString *)rawLogin server:(OCTServer *)server {
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	if (rawLogin != nil) userDict[@keypath(OCTUser.new, rawLogin)] = rawLogin;
	if (server.baseURL != nil) userDict[@keypath(OCTUser.new, baseURL)] = server.baseURL;

	return [self modelWithDictionary:userDict error:NULL];
}

#pragma mark MTLModel

- (void)mergeRawLoginFromModel:(OCTUser *)model {
	// rawLogin should always represent the username entered by the user.
	// so we don't ever want to merge this value.
}

- (NSString *)rawLogin {
	if (_rawLogin == nil) return self.login;
	return _rawLogin;
}

#pragma mark NSObject

- (NSUInteger)hash {
	if (self.objectID != nil) return self.objectID.hash ^ self.server.hash;

	if (self.rawLogin != nil) return self.server.hash ^ self.rawLogin.hash;

	return self.server.hash ^ self.login.hash;
}

- (BOOL)isEqual:(OCTUser *)user {
	if (self == user) return YES;
	if (![user isKindOfClass:self.class]) return NO;

	BOOL equalServers = [user.server isEqual:self.server];
	if (!equalServers) return NO;

	if (self.objectID != nil || user.objectID != nil) return [user.objectID isEqualToString:self.objectID];

	if (self.rawLogin != nil || user.rawLogin != nil) return [user.rawLogin isEqualToString:self.rawLogin];

	return [user.login isEqualToString:self.login];
}

@end
