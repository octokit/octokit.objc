//
//  OCTCommit.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTCommit.h"

@implementation OCTCommit

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"SHA": @"sha",
		@"treeURL": @"tree.url",
		@"treeSHA": @"tree.sha",
	}];
}

+ (NSValueTransformer *)treeURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.SHA.hash;
}

- (BOOL)isEqual:(OCTCommit *)commit {
	if (self == commit) return YES;
	if (![commit isKindOfClass:OCTCommit.class]) return NO;

	return [self.SHA isEqual:commit.SHA];
}

@end
