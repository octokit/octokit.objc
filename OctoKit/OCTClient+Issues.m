//
//  OCTClient+Issues.m
//  OctoKit
//
//  Created by leichunfeng on 15/3/7.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import "OCTClient+Issues.h"

@implementation OCTClient (Issues)

- (RACSignal *)createIssueWithTitle:(NSString *)title body:(NSString *)body assignee:(NSString *)assignee milestone:(NSUInteger)milestone labels:(NSArray *)labels inRepository:(OCTRepository *)repository {
	NSParameterAssert(title != nil);
	NSParameterAssert(repository != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"title"] = title;
	parameters[@"milestone"] = @(milestone);
	
	if (body != nil) parameters[@"body"] = body;
	if (assignee != nil) parameters[@"assignee"] = assignee;
	if (labels != nil) parameters[@"labels"] = labels;
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repository.ownerLogin, repository.name];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

@end
