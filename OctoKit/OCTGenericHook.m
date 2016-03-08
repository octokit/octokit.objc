//
//  OCTGenericHook.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTGenericHook.h"

@implementation OCTGenericHook

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"config": @"config",
	}];
}

@end
