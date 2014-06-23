//
//  OCTAccessToken.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTAccessToken.h"

@implementation OCTAccessToken

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"token": @"access_token"
	}];
}

+ (NSValueTransformer *)tokenJSONTransformer {
	// We want to prevent the token from being serialized out, so the reverse
	// transform will simply yield nil instead of the token itself.
	return [MTLValueTransformer transformerUsingForwardBlock:^(NSString *token, BOOL *success, NSError **error) {
		return token;
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return nil;
	}];
}

@end
