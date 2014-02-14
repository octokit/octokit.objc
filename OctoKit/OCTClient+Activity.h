//
//  OCTClient+Activity.h
//  OctoKit
//
//  Created by Piet Brauer on 14.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//
#import "OCTClient.h"

@class RACSignal;
@class OCTRepository;

@interface OCTClient (Activity)

// Check if the user starred the `repository`.
//
// repository - The repository used to check the starred status.
//
// Returns a signal, which will send completed on success. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)userStarredRepository:(OCTRepository *)repository;

// Star the given `repository`
//
// repository - The repository to star.
//
// Returns a signal, which will send completed on success. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)starRepository:(OCTRepository *)repository;

// Unstar the given `repository`
//
// repository - The repository to unstar.
//
// Returns a signal, which will send completed on success. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)unstarRepository:(OCTRepository *)repository;

@end
