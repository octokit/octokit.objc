//
//  OCTClient+User.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+User.h"
#import "OCTClient+Private.h"
#import "OCTUser.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchFollowers {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/followers" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchFollowing {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/following" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

@end
