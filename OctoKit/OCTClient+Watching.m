//
//  OCTClient+Watching.m
//  OctoKit
//
//  Created by Rui Peres on 15/03/2015.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

#import "OCTClient+Watching.h"
#import "OCTClient+Private.h"
#import "OCTRepository.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACSignal+OCTClientAdditions.h"

@implementation OCTClient (Watching)

- (RACSignal *)stopWatchingRepository:(OCTRepository *)repository {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
	
	NSURLRequest *request = [self requestWithMethod:@"DELETE" path:[NSString stringWithFormat:@"repos/%@/%@/subscription", repository.ownerLogin, repository.name] parameters:nil];
	
	return [[self enqueueRequest:request resultClass:nil] oct_parsedResults];
}

@end
