//
//  OCTIssueCommentEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueCommentEvent.h"
#import "OCTIssue.h"
#import "OCTIssueComment.h"

@implementation OCTIssueCommentEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"comment": @"payload.comment",
		@"issue": @"payload.issue",
	}];
}

+ (NSValueTransformer *)commentJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTIssueComment.class];
}

+ (NSValueTransformer *)issueJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTIssue.class];
}

@end
