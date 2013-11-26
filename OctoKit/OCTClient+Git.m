//
//  OCTClient+Git.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Git.h"
#import "OCTClient+Private.h"
#import "OCTRepository.h"
#import "OCTTree.h"
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
