//
//  OCTClient+Keys.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Keys.h"
#import "OCTClient+Private.h"
#import "OCTPublicKey.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Keys)

- (RACSignal *)fetchPublicKeys {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/keys" parameters:nil resultClass:OCTPublicKey.class] oct_parsedResults];
}

- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title {
	NSParameterAssert(key != nil);
	NSParameterAssert(title != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	OCTPublicKey *publicKey = [OCTPublicKey modelWithDictionary:@{
		@keypath(OCTPublicKey.new, publicKey): key,
		@keypath(OCTPublicKey.new, title): title,
	} error:NULL];
	
	NSURLRequest *request = [self requestWithMethod:@"POST" path:@"user/keys" parameters:[MTLJSONAdapter JSONDictionaryFromModel:publicKey] notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTPublicKey.class] oct_parsedResults];
}

@end
