//
//  OCTRef.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTRef.h"

@implementation OCTRef

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"name": @"ref",
		@"SHA": @"object.sha",
		@"objectURL": @"object.url",
	}];
}

+ (NSValueTransformer *)objectURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.name.hash ^ self.SHA.hash;
}

- (BOOL)isEqual:(OCTRef *)ref {
	if (self == ref) return YES;
	if (![ref isKindOfClass:OCTRef.class]) return NO;

	return [self.name isEqual:ref.name] && [self.SHA isEqual:ref.SHA];
}

@end
