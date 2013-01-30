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

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"comment": @"payload.comment",
	}];

	return keys;
}

+ (NSValueTransformer *)commentTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTPullRequestComment.class];
}

+ (NSValueTransformer *)pullRequestTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTPullRequest.class];
}

@end
