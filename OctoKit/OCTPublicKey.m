//
//  OCTPublicKey.m
//  OctoKit
//
//  Created by Josh Abernathy on 12/31/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTPublicKey.h"

@implementation OCTPublicKey

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"publicKey": @"key",
	}];
}

@end
