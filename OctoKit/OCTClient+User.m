//
//  OCTClient+User.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+User.h"
#import "OCTClient+Private.h"
#import "OCTRepository.h"
#import "OCTUser.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchUserStarredRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/starred" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	return [self createRepositoryWithName:name organization:nil team:nil description:description private:isPrivate];
}

@end
