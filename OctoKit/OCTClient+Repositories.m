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
#import "OCTRepository.h"
#import "OCTTree.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Repositories)

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

- (RACSignal *)fetchTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository recursive:(BOOL)recursive {
	NSParameterAssert(repository != nil);

	if (reference == nil) reference = @"HEAD";

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees/%@", repository.ownerLogin, repository.name, reference];
	NSDictionary *parameters;
	if (recursive) parameters = @{ @"recursive": @1 };

	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
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


@end
