//
//  OCTClient+Feed.h
//  OctoKit
//
//  Created by Yorkie on 4/27/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OCTClient.h"

@class RACSignal;
@class OCTFeed;

@interface OCTClient (Feed)

// List feeds from the current user's activity stream.
//
// Returns a signal which will send zero or more OCTFeed and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)listFeeds;

@end
