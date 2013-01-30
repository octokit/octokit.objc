//
//  OCTIssueCommentEvent.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueCommentEvent.h"
#import "OCTIssue.h"
#import "OCTIssueComment.h"

@implementation OCTIssueCommentEvent

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"comment": @"payload.comment",
		@"issue": @"payload.issue",
	}];

	return keys;
}

+ (NSValueTransformer *)commentTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTIssueComment.class];
}

+ (NSValueTransformer *)issueTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTIssue.class];
}

@end
