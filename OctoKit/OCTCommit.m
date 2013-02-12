//
//  OCTCommit.m
//  HubHub
//
//  Created by Josh Vera on 2/12/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "OCTCommit.h"

@implementation OCTCommit

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];

	[keys addEntriesFromDictionary:@{
		@"sha": @"sha",
		@"URL": @"url",
		@"author": @"author",
		@"committer": @"committer",
		@"message": @"message"
	}];

	return keys;
}
@end
