//
//  OCTClient+Git.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Git.h"
#import "OCTClient+Private.h"
#import "OCTCommit.h"
#import "OCTRef.h"
#import "OCTRepository.h"
#import "OCTResponse.h"
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

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTTree.class] oct_parsedResults];
}

- (RACSignal *)createTreeWithEntries:(NSArray *)treeEntries inRepository:(OCTRepository *)repository basedOnTreeWithSHA:(NSString *)baseTreeSHA {
	NSParameterAssert(treeEntries != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees", repository.ownerLogin, repository.name];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"tree"] = [[treeEntries.rac_sequence
		map:^(OCTTreeEntry *entry) {
			return [MTLJSONAdapter JSONDictionaryFromModel:entry];
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

	return [self createBlobWithString:string inRepository:repository withEncoding:OCTContentEncodingUTF8];
}

- (RACSignal *)createBlobWithString:(NSString *)string inRepository:(OCTRepository *)repository withEncoding:(OCTContentEncoding)encoding {
	NSParameterAssert(string != nil);
	NSParameterAssert(repository != nil);
	
	NSArray *encodings = @[ @"utf-8", @"base64" ];

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/blobs", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:@{
		@"content": string,
		@"encoding": encodings[encoding]
	} notMatchingEtag:nil];

	return [[self
		enqueueRequest:request resultClass:nil]
		map:^(OCTResponse *response) {
			return response.parsedResult[@"sha"];
		}];
}

- (RACSignal *)fetchCommit:(NSString *)commitSHA inRepository:(OCTRepository *)repository {
	NSParameterAssert(commitSHA != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/commits/%@", repository.ownerLogin, repository.name, commitSHA];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	return [[self enqueueRequest:request resultClass:OCTCommit.class] oct_parsedResults];
}

- (RACSignal *)createCommitWithMessage:(NSString *)message inRepository:(OCTRepository *)repository pointingToTreeWithSHA:(NSString *)treeSHA parentCommitSHAs:(NSArray *)parentSHAs {
	NSParameterAssert(message != nil);
	NSParameterAssert(repository != nil);
	NSParameterAssert(treeSHA != nil);
	NSParameterAssert(parentSHAs != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/commits", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:@{
		@"message": message,
		@"tree": treeSHA,
		@"parents": parentSHAs,
	} notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTCommit.class] oct_parsedResults];
}

- (RACSignal *)fetchAllReferencesInRepository:(OCTRepository *)repository {
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/refs", repository.ownerLogin, repository.name];

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTRef.class] oct_parsedResults];
}

- (RACSignal *)fetchReference:(NSString *)refName inRepository:(OCTRepository *)repository {
	NSParameterAssert(refName != nil);
	NSParameterAssert(repository != nil);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/refs/%@", repository.ownerLogin, repository.name, refName];

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

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
