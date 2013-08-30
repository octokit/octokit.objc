//
//  OCTComment.m
//  OctoKit
//
//  Created by Josh Vera on 6/26/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTComment.h"
#import "OCTUser.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTComment

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"body": @"body",
		@"HTMLBody": @"body_html",
		@"createdAtDate": @"created_at",
		@"updatedAtDate": @"updated_at",
		@"HTMLURL": @"html_url",
		@"commenterLogin": @"user.login",
		@"APIURL": @"url"
	}];
}

+ (NSValueTransformer *)createdAtDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedAtDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)APIURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
