//
//  OCTStatus.m
//  OctoKit
//
//  Created by Jackson Harper on 1/10/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTStatus.h"

@implementation OCTStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"URL" : @"url",
		@"objectID": @"id",
		@"targetURL": @"target_url",
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at",
		@"message": @"description",
	}];
}

+ (NSValueTransformer *)URLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)targetURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)stateJSONTransformer {
	NSDictionary *statesByName = @{
		@"pending": @(OCTStatusStatePending),
		@"success": @(OCTStatusStateSuccess),
		@"error": @(OCTStatusStateError),
		@"failure": @(OCTStatusStateFailure),
	};

	return [MTLValueTransformer
			reversibleTransformerWithForwardBlock:^(NSString *stateName) {
				return statesByName[stateName];
			}
			reverseBlock:^(NSNumber *state) {
				return [statesByName allKeysForObject:state].lastObject;
			}];
}

@end
