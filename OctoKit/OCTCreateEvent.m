//
//  OCTCreateEvent.m
//  OctoKit
//
//  Created by Josh Vera on 6/19/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTCreateEvent.h"

@implementation OCTCreateEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"masterBranch": @"payload.master_branch",
		@"repositoryDescription": @"payload.description"
	}];
}

@end
