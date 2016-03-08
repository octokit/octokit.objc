//
//  OCTClient+Repositories.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Repositories.h"
#import "OCTClient+Private.h"
#import "OCTCommitCombinedStatus.h"
#import "OCTCommitStatus.h"
#import "OCTContent.h"
#import "OCTOrganization.h"
#import "OCTRepository.h"
#import "OCTTeam.h"
#import "OCTBranch.h"

@implementation OCTClient (Repositories)

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchPublicRepositoriesForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	perPage = [self perPageWithPerPage:perPage];
	
	NSUInteger page = [self pageWithOffset:offset perPage:perPage];
	NSUInteger pageOffset = [self pageOffsetWithOffset:offset perPage:perPage];
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"/users/%@/repos", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTRepository.class fetchAllPages:YES] oct_parsedResults] skip:pageOffset];
}

- (RACSignal *)fetchUserStarredRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/starred" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchStarredRepositoriesForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage {
	NSParameterAssert(user != nil);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	perPage = [self perPageWithPerPage:perPage];
	
	NSUInteger page = [self pageWithOffset:offset perPage:perPage];
	NSUInteger pageOffset = [self pageOffsetWithOffset:offset perPage:perPage];
	
	parameters[@"page"] = @(page);
	parameters[@"per_page"] = @(perPage);
	
	NSString *path = [NSString stringWithFormat:@"/users/%@/starred", user.login];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[[self enqueueRequest:request resultClass:OCTRepository.class fetchAllPages:YES] oct_parsedResults] skip:pageOffset];
}

- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization {
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/repos", organization.login] parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	return [self createRepositoryWithName:name organization:nil team:nil description:description private:isPrivate];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"name"] = name;
	options[@"private"] = @(isPrivate);

	if (description != nil) options[@"description"] = description;
	if (team != nil) options[@"team_id"] = team.objectID;
	
	NSString *path = (organization == nil ? @"user/repos" : [NSString stringWithFormat:@"orgs/%@/repos", organization.login]);
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:options notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	relativePath = relativePath ?: @"";
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/contents/%@", repository.ownerLogin, repository.name, relativePath];
	
	NSDictionary *parameters = nil;
	if (reference.length > 0) {
		parameters = @{ @"ref": reference };
	}
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository {
	return [self fetchRepositoryReadme:repository reference:nil];
}

- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository reference:(NSString *)reference {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/readme", repository.ownerLogin, repository.name];
	NSDictionary *parameters = (reference.length > 0 ? @{ @"ref": reference } : nil);
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchBranchesForRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/branches", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTBranch.class] oct_parsedResults];
}

- (RACSignal *)fetchOpenPullRequestsForRepositoryWithName:(NSString *)name owner:(NSString *)owner {
    NSParameterAssert(name.length > 0);
    NSParameterAssert(owner.length > 0);
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/pulls", owner, name];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
    
    return [[self enqueueRequest:request resultClass:OCTPullRequest.class] oct_parsedResults];
}

- (RACSignal *)fetchClosedPullRequestsForRepositoryWithName:(NSString *)name owner:(NSString *)owner {
    NSParameterAssert(name.length > 0);
    NSParameterAssert(owner.length > 0);
    
    NSDictionary *options = @{ @"state": @"closed" };
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/pulls", owner, name];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:options notMatchingEtag:nil];
    
    return [[self enqueueRequest:request resultClass:OCTPullRequest.class] oct_parsedResults];
}

- (RACSignal *)fetchSinglePullRequestForRepositoryWithName:(NSString *)name owner:(NSString *)owner number:(NSInteger)number {
    NSParameterAssert(name.length > 0);
    NSParameterAssert(owner.length > 0);
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/pulls/%ld", owner, name, (long)number];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
    
    return [[self enqueueRequest:request resultClass:OCTPullRequest.class] oct_parsedResults];
}

- (RACSignal *)createPullRequestInRepository:(OCTRepository *)repository title:(NSString *)title body:(NSString *)body baseBranch:(NSString *)baseBranch headBranch:(NSString *)headBranch {
	NSParameterAssert(repository !=  nil);
	NSParameterAssert(title != nil);
	NSParameterAssert(baseBranch != nil);
	NSParameterAssert(headBranch != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/pulls", repository.ownerLogin, repository.name];
	NSMutableDictionary *params = [@{ @"title": title, @"head": headBranch, @"base": baseBranch } mutableCopy];
	if (body != nil) params[@"body"] = body;

	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:params notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTPullRequest.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitsFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA {
	NSParameterAssert(repository);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits", repository.ownerLogin, repository.name];

	NSDictionary *parameters = nil;
	if (SHA.length > 0) {
		parameters = @{ @"sha": SHA };
	}

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTGitCommit.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA {
	NSParameterAssert(repository);
	NSParameterAssert(SHA.length > 0);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits/%@", repository.ownerLogin, repository.name, SHA];
	NSDictionary *parameters = @{@"sha": SHA};
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTGitCommit.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitStatusesForRepositoryWithName:(NSString *)name owner:(NSString *)owner reference:(NSString *)reference {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	NSParameterAssert(reference.length > 0);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits/%@/statuses", owner, name, reference];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTCommitStatus.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitCombinedStatusForRepositoryWithName:(NSString *)name owner:(NSString *)owner reference:(NSString *)reference {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	NSParameterAssert(reference.length > 0);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits/%@/status", owner, name, reference];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTCommitCombinedStatus.class] oct_parsedResults];
}

@end
