//
//  OCTCommitCommentEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTCommitCommentEvent.h"
#import "OCTCommitComment.h"

@implementation OCTCommitCommentEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"comment": @"payload.comment",
	}];
}

+ (NSValueTransformer *)commentJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTCommitComment.class];
}

@end
