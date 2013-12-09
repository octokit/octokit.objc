//
//  OCTClient+Commits.m
//  OctoKit
//
//  Created by Jackson Harper on 12/9/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Commits.h"
#import "OCTCommit.h"


@implementation OCTClient (Commits)


- (RACSignal *)fetchCommitsForPullRequest:(OCTPullRequest *)pullRequest
{
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/repos/%@/%@/pulls/%@/commits", pullRequest.baseRepository.ownerLogin, pullRequest.baseRepository.name, pullRequest.objectID] parameters:nil notMatchingEtag:nil];

    return [[self enqueueRequest:request resultClass:[OCTCommit class]] oct_parsedResults];
}

@end
