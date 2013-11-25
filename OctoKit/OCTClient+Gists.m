//
//  OCTClient+Gists.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Gists.h"
#import "OCTClient+Private.h"
#import "OCTGist.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Gists)

- (RACSignal *)fetchGists {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:@"gists" parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

- (RACSignal *)applyEdit:(OCTGistEdit *)edit toGist:(OCTGist *)gist {
	NSParameterAssert(edit != nil);
	NSParameterAssert(gist != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
	NSURLRequest *request = [self requestWithMethod:@"PATCH" path:[NSString stringWithFormat:@"gists/%@", gist.objectID] parameters:parameters notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

- (RACSignal *)createGistWithEdit:(OCTGistEdit *)edit {
	NSParameterAssert(edit != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:@"gists" parameters:parameters notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

@end
