//
//  OCTGistFile.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-07-31.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTGistFile.h"

@implementation OCTGistFile

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"rawURL": @"raw_url",
	}];
}

+ (NSValueTransformer *)rawURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end

@implementation OCTGistFileEdit

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{};
}

@end
