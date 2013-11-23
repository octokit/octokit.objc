//
//  OCTClient+Git.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Git.h"
#import "OCTClient+Private.h"
#import "OCTRef.h"
#import "OCTRepository.h"
#import "OCTTree.h"
#import "OCTTreeEntry.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Git)

- (RACSignal *)fetchTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository recursive:(BOOL)recursive {
	NSParameterAssert(repository != nil);

	if (reference == nil) reference = @"HEAD";

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees/%@", repository.ownerLogin, repository.name, reference];
	NSDictionary *parameters;
	if (recursive) parameters = @{ @"recursive": @1 };

	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	return [[self enqueueRequest:request resultClass:OCTTree.class] oct_parsedResults];
}

- (RACSignal *)createTreeWithEntries:(NSArray *)treeEntries inRepository:(OCTRepository *)repository basedOnTreeWithSHA:(NSString *)baseTreeSHA {
	NSParameterAssert(treeEntries != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees", repository.ownerLogin, repository.name];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"tree"] = [[treeEntries.rac_sequence
		flattenMap:^(OCTTreeEntry *entry) {
			NSDictionary *entryJSON = [MTLJSONAdapter JSONDictionaryFromModel:entry];

			// TODO: Real error handling
			if (entryJSON == nil) return [RACSequence empty];

			return [RACSequence return:entryJSON];
		}]
		array];

	if (baseTreeSHA != nil) parameters[@"base_tree"] = baseTreeSHA;

	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	return [[self enqueueRequest:request resultClass:OCTTree.class] oct_parsedResults];
}

- (RACSignal *)fetchBlob:(NSString *)blobSHA inRepository:(OCTRepository *)repository {
	NSParameterAssert(blobSHA != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/blobs/%@", repository.ownerLogin, repository.name, blobSHA];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];

	NSString *contentType = [NSString stringWithFormat:@"application/vnd.github.%@.raw", OCTClientAPIVersion];
	[request setValue:contentType forHTTPHeaderField:@"Accept"];

	return [[self
		enqueueRequest:request fetchAllPages:NO]
		reduceEach:^(NSHTTPURLResponse *response, NSData *data) {
			return data;
		}];
}

- (RACSignal *)createBlobWithString:(NSString *)string inRepository:(OCTRepository *)repository {
	NSParameterAssert(string != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/blobs", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:@{
		@"content": string,
		@"encoding": @"utf-8"
	} notMatchingEtag:nil];

	return [[self
		enqueueRequest:request resultClass:nil]
		map:^(OCTResponse *response) {
			return response.parsedResult[@"sha"];
		}];
}

- (RACSignal *)fetchReference:(NSString *)refName inRepository:(OCTRepository *)repository {
	NSParameterAssert(refName != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/refs/%@", repository.ownerLogin, repository.name, refName];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	return [[self enqueueRequest:request resultClass:OCTRef.class] oct_parsedResults];
}

- (RACSignal *)updateReference:(NSString *)refName inRepository:(OCTRepository *)repository toSHA:(NSString *)newSHA force:(BOOL)force {
	NSParameterAssert(refName != nil);
	NSParameterAssert(repository != nil);
	NSParameterAssert(newSHA != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/refs/%@", repository.ownerLogin, repository.name, refName];
	NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:@{
		@"sha": newSHA,
		@"force": @(force)
	}];

	return [[self enqueueRequest:request resultClass:OCTRef.class] oct_parsedResults];
}

@end
