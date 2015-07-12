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

- (RACSignal *)fetchEventsForUser:(OCTUser *)user page:(NSUInteger)page perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (page >= 1) {
		parameters[@"page"] = @(page);
	}
	
	if (perPage >= 1 && perPage <= 100) {
		parameters[@"per_page"] = @(perPage);
	} else {
		parameters[@"per_page"] = @(30);
	}
	
	NSString *path = [NSString stringWithFormat:@"users/%@/received_events", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTEvent.class fetchAllPages:NO] oct_parsedResults];
}

@end
