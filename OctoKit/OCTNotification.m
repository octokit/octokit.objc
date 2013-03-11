//
//  OCTNotification.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/22/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTNotification.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"
#import "OCTRepository.h"

@implementation OCTNotification

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"title": @"subject.title",
		@"threadURL": @"url",
		@"subjectURL": @"subject.url",
		@"latestCommentURL": @"subject.latest_comment_url",
		@"type": @"subject.type",
		@"repository": @"repository",
		@"lastUpdatedDate": @"updated_at",
	}];
}

+ (NSValueTransformer *)objectIDJSONTransformer {
	return [MTLValueTransformer transformerWithBlock:^ id (id num) {
		if ([num isKindOfClass:NSString.class]) {
			return num;
		} else if ([num isKindOfClass:NSNumber.class]) {
			return [num stringValue];
		} else {
			return nil;
		}
	}];
}

+ (NSValueTransformer *)threadURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)subjectURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)latestCommentURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)repositoryJSONTransformer {
	return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)lastUpdatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)typeJSONTransformer {
	NSDictionary *typesByName = @{
		@"Issue": @(OCTNotificationTypeIssue),
		@"PullRequest": @(OCTNotificationTypePullRequest),
		@"Commit": @(OCTNotificationTypeCommit),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *name) {
			return typesByName[name] ?: @(OCTNotificationTypeUnknown);
		} reverseBlock:^(NSNumber *type) {
			return [typesByName allKeysForObject:type].lastObject;
		}];
}

@end
