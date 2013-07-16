//
//  OCTSubmoduleContent.m
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTSubmoduleContent.h"

@implementation OCTSubmoduleContent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"submoduleGitURL": @"submodule_git_url",
	}];
}

@end
