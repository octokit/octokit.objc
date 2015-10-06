//
//  OCTPullRequest.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequest.h"

#import "OCTUser.h"
#import "OCTRepository.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTPullRequest

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"URL" : @"url",
		@"HTMLURL": @"html_url",
		@"diffURL": @"diff_url",
		@"patchURL": @"patch_url",
		@"issueURL": @"issue_url",
		@"objectID": @"number",
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at",
		@"closedDate": @"closed_at",
		@"mergedDate": @"merged_at",
		@"headRepository": @"head.repo",
		@"baseRepository": @"base.repo",
		@"headBranch": @"head.ref",
		@"baseBranch": @"base.ref",
	}];
}

+ (NSValueTransformer *)URLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)diffURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)patchURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)issueURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTUser.class];
}

+ (NSValueTransformer *)assigneeJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTUser.class];
}

+ (NSValueTransformer *)stateJSONTransformer {
	NSDictionary *statesByName = @{
		@"open": @(OCTPullRequestStateOpen),
		@"closed": @(OCTPullRequestStateClosed),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *stateName) {
			return statesByName[stateName];
		}
		reverseBlock:^(NSNumber *state) {
			return [statesByName allKeysForObject:state].lastObject;
		}];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)closedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)mergedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)headRepositoryJSONTransformer {
	return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)baseRepositoryJSONTransformer {
	return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

@end
