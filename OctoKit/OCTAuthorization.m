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

- (NSValueTransformer *)JSONTransformerForToken {
	// We want to prevent the token from being serialized out, so the reverse
	// transform will simply yield an empty string instead of the token itself.
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *token) {
		return token;
	} reverseBlock:^(NSString *token) {
		return @"";
	}];
}

@end
