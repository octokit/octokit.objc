//
//  OCTClient+Events.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Events.h"
#import "OCTClient+Private.h"
#import "OCTEvent.h"
#import "OCTUser.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACSignal+OCTClientAdditions.h"

@implementation OCTClient (Events)

- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag {
	if (self.user == nil) return [RACSignal error:self.class.userRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"users/%@/received_events", self.user.login] parameters:nil notMatchingEtag:etag];
	
	return [self enqueueRequest:request resultClass:OCTEvent.class fetchAllPages:NO];
}

- (RACSignal *)fetchUserReceivedEventsWithOffset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (perPage == 0 || perPage > 100) {
		perPage = 30;
	}
	
	NSUInteger page = (offset / perPage) + 1;
	NSUInteger pageOffset = offset % perPage;
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"users/%@/received_events", self.user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTEvent.class fetchAllPages:NO] oct_parsedResults] skip:pageOffset];
}

- (RACSignal *)fetchPerformedEventsForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (perPage == 0 || perPage > 100) {
		perPage = 30;
	}
	
	NSUInteger page = (offset / perPage) + 1;
	NSUInteger pageOffset = offset % perPage;
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"users/%@/events", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTEvent.class fetchAllPages:NO] oct_parsedResults] skip:pageOffset];
}

@end
