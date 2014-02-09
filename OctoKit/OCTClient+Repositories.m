//
//  OCTClient+Repositories.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Repositories.h"
#import "OCTClient+Private.h"
#import "OCTContent.h"
#import "OCTOrganization.h"
#import "OCTRepository.h"
#import "OCTTeam.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OCTGitCommit.h"

@implementation OCTClient (Repositories)

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchUserStarredRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/starred" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
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
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/readme", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitsForRepositoryWithName:(NSString *)name owner:(NSString *)owner sha:(NSString *)SHA {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits", owner, name];

	NSDictionary *parameters = nil;
	if (SHA.length > 0) {
		parameters = @{ @"sha": SHA };
	}

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTGitCommit.class] oct_parsedResults];
}

@end
