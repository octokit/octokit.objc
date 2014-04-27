//
//  OCTClient+Feed.m
//  OctoKit
//
//  Created by Yorkie on 4/27/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTClient+Feed.h"
#import "OCTClient+Private.h"
#import "OCTFeed.h"

@implementation OCTClient (Feed)

- (RACSignal *)listFeeds {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
	
	NSString *path = @"/feeds";
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	return [[self enqueueRequest:request resultClass:OCTFeed.class] oct_parsedResults];
}

@end
