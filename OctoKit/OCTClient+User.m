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

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchFollowersWithPage:(NSUInteger)page {
	NSMutableDictionary *parameters = nil;
	
	if (page >= 1) {
		parameters = [NSMutableDictionary dictionary];
		parameters[@"page"] = @(page);
	}
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:@"/user/followers" parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTUser.class fetchAllPages:NO] oct_parsedResults];
}

- (RACSignal *)fetchFollowingWithPage:(NSUInteger)page {
	NSMutableDictionary *parameters = nil;
	
	if (page >= 1) {
		parameters = [NSMutableDictionary dictionary];
		parameters[@"page"] = @(page);
	}
	
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/following" parameters:parameters resultClass:OCTUser.class] oct_parsedResults];
}

@end
