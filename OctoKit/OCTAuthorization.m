//
//  OCTAuthorization.m
//  OctoKit
//
//  Created by Josh Abernathy on 7/25/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTAuthorization.h"

@implementation OCTAuthorization

#pragma mark MTLJSONSerializing

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
