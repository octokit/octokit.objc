//
//  OCTClient+User.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+User.h"
#import "OCTClient+Private.h"
#import "OCTUser.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OCTResponse.h"

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchUserInfoForUser:(OCTUser *)user {
	NSParameterAssert(user != nil);
	
	NSString *path = [NSString stringWithFormat:@"/users/%@", user.login];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchFollowersForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	perPage = [self perPageWithPerPage:perPage];
	
	NSUInteger page = [self pageWithOffset:offset perPage:perPage];
	NSUInteger pageOffset = [self pageOffsetWithOffset:offset perPage:perPage];
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"/users/%@/followers", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTUser.class fetchAllPages:YES] oct_parsedResults] skip:pageOffset];
}

- (RACSignal *)fetchFollowingForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	perPage = [self perPageWithPerPage:perPage];
	
	NSUInteger page = [self pageWithOffset:offset perPage:perPage];
	NSUInteger pageOffset = [self pageOffsetWithOffset:offset perPage:perPage];
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"/users/%@/following", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTUser.class fetchAllPages:YES] oct_parsedResults] skip:pageOffset];
}

- (RACSignal *)doesFollowUser:(OCTUser *)user {
	NSParameterAssert(user != nil);
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
	
	NSString *relativePath = [NSString stringWithFormat:@"/following/%@", user.login];
	
	return [[[self
		enqueueUserRequestWithMethod:@"GET" relativePath:relativePath parameters:nil resultClass:nil]
		map:^(OCTResponse *response) {
			return @(response.statusCode == 204);
		}]
		catch:^(NSError *error) {
			NSNumber *statusCode = error.userInfo[OCTClientErrorHTTPStatusCodeKey];
			if (statusCode.integerValue == 404) {
				return [RACSignal return:@NO];
			} else {
				return [RACSignal error:error];
			}
		}];
}

- (RACSignal *)followUser:(OCTUser *)user {
	NSParameterAssert(user != nil);
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
	
	NSString *relativePath = [NSString stringWithFormat:@"/following/%@", user.login];
	return [[self enqueueUserRequestWithMethod:@"PUT" relativePath:relativePath parameters:nil resultClass:OCTUser.class] ignoreValues];
}

- (RACSignal *)unfollowUser:(OCTUser *)user {
	NSParameterAssert(user != nil);
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
	
	NSString *relativePath = [NSString stringWithFormat:@"/following/%@", user.login];
	return [[self enqueueUserRequestWithMethod:@"DELETE" relativePath:relativePath parameters:nil resultClass:OCTUser.class] ignoreValues];
}

@end
