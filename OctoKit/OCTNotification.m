//
//  OCTNotification.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/22/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTNotification.h"

@implementation OCTNotification

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];

	[keys addEntriesFromDictionary:@{
		@"title": @"subject.title",
		@"threadURL": @"url",
		@"subjectURL": @"subject.url",
		@"type": @"subject.type",
	 }];

	return keys;
}

+ (NSValueTransformer *)threadURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)subjectURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)typeTransformer {
	NSDictionary *typesByName = @{
		@"Issue": @(OCTNotificationTypeIssue),
		@"PullRequest": @(OCTNotificationTypePullRequest),
		@"Commit": @(OCTNotificationTypeCommit),
	};

	return [MTLValueTransformer transformerWithBlock:^(NSString *name) {
		return typesByName[name];
	}];
}

@end
