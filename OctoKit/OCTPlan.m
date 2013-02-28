//
//  OCTPlan.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTPlan.h"

@implementation OCTPlan

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"privateRepos": @"private_repos",
	}];
}

@end
