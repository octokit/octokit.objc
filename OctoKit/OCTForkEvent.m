//
//  OCTForkEvent.m
//  OctoKit
//
//  Created by Tyler Stromberg on 12/25/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTForkEvent.h"

@implementation OCTForkEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"forkedRepositoryName": @"payload.forkee.full_name",
	}];
}

@end
