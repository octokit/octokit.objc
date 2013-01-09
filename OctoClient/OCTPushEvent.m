//
//  OCTPushEvent.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPushEvent.h"

@implementation OCTPushEvent

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"commitCount": @"payload.size",
		@"distinctCommitCount": @"payload.distinct_size",
		@"previousHeadSHA": @"payload.before",
		@"currentHeadSHA": @"payload.head",
		@"branchName": @"payload.ref",
	}];

	return keys;
}

+ (NSValueTransformer *)branchNameTransformer {
	static NSString * const branchRefPrefix = @"refs/heads/";

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSString *ref) {
			if (![ref hasPrefix:branchRefPrefix]) {
				NSLog(@"%s: Unrecognized ref prefix: %@", __func__, ref);
				return nil;
			}

			return [ref substringFromIndex:branchRefPrefix.length];
		}
		reverseBlock:^(NSString *branch) {
			return [branchRefPrefix stringByAppendingString:branch];
		}];
}

@end
