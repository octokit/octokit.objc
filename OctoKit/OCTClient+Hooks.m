//
//  OCTClient+Hooks.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTClient+Hooks.h"
#import "OCTRepository.h"
#import "OCTWebHook.h"
#import "RACSignal+OCTClientAdditions.h"

@implementation OCTClient (Hooks)


- (RACSignal *)createHookForEvents:(NSArray *)events active:(BOOL)active withName:(NSString *)name config:(NSDictionary *)config inRepository:(OCTRepository *)repository {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(repository != nil);

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"events"] = events != nil ? events : @[@"*"];
	parameters[@"active"] = @(active);
	parameters[@"name"] = name;
	parameters[@"config"] = config != nil ? config : @{};

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/hooks", repository.ownerLogin, repository.name];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTWebHook.class] oct_parsedResults];
}

- (RACSignal *)createWebHookForEvents:(NSArray *)events active:(BOOL)active withURL:(NSURL *)url contentType:(NSString *)contentType secret:(NSString *)secret insecureSSL:(BOOL)insecureSSL inRepository:(OCTRepository *)repository {
	NSParameterAssert(url != nil);
	NSParameterAssert(contentType.length > 0);

	NSMutableDictionary *config = [NSMutableDictionary dictionary];
	config[@"url"] = [url absoluteString];
	config[@"content_type"] = contentType;
	config[@"insecure_ssl"] = insecureSSL ? @"1" : @"0";

	if (secret.length > 0) {
		config[@"secret"] = secret;
	}

	return [self createHookForEvents:events active:active withName:@"web" config:config inRepository:repository];
}

@end
