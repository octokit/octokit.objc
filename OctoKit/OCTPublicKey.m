//
//  OCTPublicKey.m
//  OctoKit
//
//  Created by Josh Abernathy on 12/31/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTPublicKey.h"

@implementation OCTPublicKey

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"publicKey": @"key",
	}];

	return keys;
}

@end
