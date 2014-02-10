//
//  OCTBranch.m
//  OctoKit
//
//  Created by Piet Brauer on 08.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTBranch.h"

@implementation OCTBranch

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		  @"lastCommitSHA": @"commit.sha",
		  @"lastCommitURL": @"commit.url",
	}];
}

+ (NSValueTransformer *)lastCommitURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
