//
//  OCTClient+Issues.m
//  OctoKit
//
//  Created by leichunfeng on 15/3/7.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import "OCTClient+Issues.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"

@implementation OCTClient (Issues)

- (RACSignal *)createIssueWithTitle:(NSString *)title body:(NSString *)body assignee:(NSString *)assignee milestone:(NSNumber *)milestone labels:(NSArray *)labels inRepository:(OCTRepository *)repository {
	NSParameterAssert(title != nil);
	NSParameterAssert(repository != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"title"] = title;
	
	if (milestone != nil) parameters[@"milestone"] = milestone;
	if (body != nil) parameters[@"body"] = body;
	if (assignee != nil) parameters[@"assignee"] = assignee;
	if (labels != nil) parameters[@"labels"] = labels;
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repository.ownerLogin, repository.name];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

- (RACSignal *)fetchIssuesForRepository:(OCTRepository *)repository state:(OCTClientIssueState)state notMatchingEtag:(NSString *)etag since:(NSDate *)since {
	NSParameterAssert(repository != nil);

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

	NSDictionary *stateToStateString = @{
		@(OCTClientIssueStateOpen): @"open",
		@(OCTClientIssueStateClosed): @"closed",
		@(OCTClientIssueStateAll): @"all",
	};
	NSString *stateString = stateToStateString[@(state)];
	NSAssert(stateString != nil, @"Unknown state: %@", @(state));

	parameters[@"state"] = stateString;
	if (since != nil) parameters[@"since"] = [NSDateFormatter oct_stringFromDate:since];

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repository.ownerLogin, repository.name];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:etag];
	return [self enqueueRequest:request resultClass:OCTIssue.class];
}

@end
