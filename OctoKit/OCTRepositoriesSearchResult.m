//
//  OCTRepositoriesSearchResult.m
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import "OCTRepositoriesSearchResult.h"

@implementation OCTRepositoriesSearchResult

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"totalCount": @"total_count",
		@"incompleteResults": @"incomplete_results",
		@"repositories": @"items",
	}];
}

+ (NSValueTransformer *)repositoriesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:OCTRepository.class];
}

@end
