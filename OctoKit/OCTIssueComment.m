//
//  OCTIssueComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueComment.h"
#import "OCTUser.h"
#import "ISO8601DateFormatter.h"

@implementation OCTIssueComment

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];

	[keys addEntriesFromDictionary:@{
		@"body": @"body",
		@"user": @"user",
		@"created": @"created_at",
		@"updated": @"updated_at",
	 }];

	return keys;
}

+ (NSValueTransformer *)createdTransformer {
	return [MTLValueTransformer transformerWithBlock:^ id (id date) {
		if (![date isKindOfClass:NSString.class]) return date;

		return [[[ISO8601DateFormatter alloc] init] dateFromString:date];
	}];
}

+ (NSValueTransformer *)updatedTransformer {
	return [MTLValueTransformer transformerWithBlock:^ id (id date) {
		if (![date isKindOfClass:NSString.class]) return date;

		return [[[ISO8601DateFormatter alloc] init] dateFromString:date];
	}];
}

+ (NSValueTransformer *)userTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTUser.class];
}

@end
