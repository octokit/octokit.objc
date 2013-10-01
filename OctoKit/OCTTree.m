//
//  OCTTree.m
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTTree.h"
#import "OCTTreeEntry.h"

@implementation OCTTree

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"SHA": @"sha",
		@"URL": @"url",
		@"entries": @"tree",
	}];
}

+ (NSValueTransformer *)URLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)entriesJSONTransformer {
	return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:OCTTreeEntry.class];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.URL.hash;
}

- (BOOL)isEqual:(OCTTree *)tree {
	if (self == tree) return YES;
	if (![tree isKindOfClass:self.class]) return NO;

	return [tree.URL isEqual:self.URL];
}

@end
