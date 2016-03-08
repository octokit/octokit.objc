//
//  OCTCommitCombinedStatus.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/7/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTCommitCombinedStatus.h"
#import "OCTRepository.h"
#import "OCTCommitStatus.h"

@implementation OCTCommitCombinedStatus

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"state": @"state",
		@"SHA": @"sha",
		@"countOfStatuses": @"total_count",
		@"statuses": @"statuses",
		@"repository": @"repository",
		@"commitURL": @"commit_url"
	}];
}

+ (NSValueTransformer *)statusesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:OCTCommitStatus.class];
}

+ (NSValueTransformer *)repositoryJSONTransformer {
	return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

@end
