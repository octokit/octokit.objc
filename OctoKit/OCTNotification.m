//
//  OCTNotification.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/22/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTNotification.h"
#import "OCTRepository.h"
#import "ISO8601DateFormatter.h"

@implementation OCTNotification

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];

	[keys addEntriesFromDictionary:@{
		@"title": @"subject.title",
		@"threadURL": @"url",
		@"subjectURL": @"subject.url",
		@"type": @"subject.type",
		@"repository": @"repository",
		@"lastUpdatedDate": @"updated_at",
	 }];

	return keys;
}

+ (NSValueTransformer *)threadURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)subjectURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)repositoryTransformer {
	return [MTLValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)lastUpdatedDateTransformer {
	return [MTLValueTransformer transformerWithBlock:^ id (id date) {
		if (![date isKindOfClass:NSString.class]) return date;

		return [[[ISO8601DateFormatter alloc] init] dateFromString:date];
	}];
}

+ (NSValueTransformer *)typeTransformer {
	NSDictionary *typesByName = @{
		@"Issue": @(OCTNotificationTypeIssue),
		@"PullRequest": @(OCTNotificationTypePullRequest),
		@"Commit": @(OCTNotificationTypeCommit),
	};

	return [MTLValueTransformer transformerWithBlock:^(NSString *name) {
		// If it's some unknown type, let's just pretend it's an issue for now.
		return typesByName[name] ?: @(OCTNotificationTypeIssue);
	}];
}

@end
