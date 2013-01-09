//
//  OCTCommitCommentEvent.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTCommitCommentEvent.h"
#import "OCTCommitComment.h"

@implementation OCTCommitCommentEvent

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"comment": @"payload.comment",
	}];

	return keys;
}

+ (NSValueTransformer *)commentTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTCommitComment.class];
}

@end
