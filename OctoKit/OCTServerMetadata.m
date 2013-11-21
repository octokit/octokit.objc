//
//  OCTServerMetadata.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-14.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTServerMetadata.h"

@implementation OCTServerMetadata

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"supportsPasswordAuthentication": @"verifiable_password_authentication"
	}];
}

@end
