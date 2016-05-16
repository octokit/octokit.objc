//
//  OCTCommitStatus.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/7/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTCommitStatus.h"
#import "OCTUser.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

NSString * const OCTCommitStatusStateSuccess = @"success";
NSString * const OCTCommitStatusStateFailure = @"failure";
NSString * const OCTCommitStatusStateError = @"error";
NSString * const OCTCommitStatusStatePending = @"pending";

@implementation OCTCommitStatus

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at",
		@"state": @"state",
		@"targetURL": @"target_url",
		@"statusDescription": @"description",
		@"context": @"context",
		@"creator": @"creator"
	}];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)targetURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creatorJSONTransformer {
	return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTUser.class];
}

@end
