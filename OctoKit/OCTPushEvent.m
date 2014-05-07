//
//  OCTPushEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPushEvent.h"

@implementation OCTPushEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"commitCount": @"payload.size",
		@"distinctCommitCount": @"payload.distinct_size",
		@"previousHeadSHA": @"payload.before",
		@"currentHeadSHA": @"payload.head",
		@"branchName": @"payload.ref",
	}];
}

+ (NSValueTransformer *)branchNameJSONTransformer {
	static NSString * const branchRefPrefix = @"refs/heads/";

	return [MTLValueTransformer
		transformerUsingForwardBlock:^ id (NSString *ref, BOOL *success, NSError **error) {
			if (![ref hasPrefix:branchRefPrefix]) {
				NSLog(@"%s: Unrecognized ref prefix: %@", __func__, ref);

				if (success != NULL) *success = NO;

				return nil;
			}

			return [ref substringFromIndex:branchRefPrefix.length];
		}
		reverseBlock:^(NSString *branch, BOOL *success, NSError **error) {
			return [branchRefPrefix stringByAppendingString:branch];
		}];
}

@end
