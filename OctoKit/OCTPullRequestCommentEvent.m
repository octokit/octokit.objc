//
//  OCTPullRequestCommentEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequestCommentEvent.h"
#import "OCTPullRequest.h"
#import "OCTPullRequestComment.h"

@implementation OCTPullRequestCommentEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"comment": @"payload.comment",
	}];
}

+ (NSValueTransformer *)commentJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTPullRequestComment.class];
}

+ (NSValueTransformer *)pullRequestJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTPullRequest.class];
}

@end
