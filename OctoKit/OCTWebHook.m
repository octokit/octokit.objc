//
//  OCTWebHook.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTWebHook.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

NSString * const OCTWebHookContentTypeJSON = @"json";
NSString * const OCTWebHookContentTypeURLEncodedForm = @"form";

@implementation OCTWebHook

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"hookURL": @"config.url",
		@"contentType": @"config.content_type",
		@"secret": @"config.secret",
		@"insecureSSL": @"config.insecure_ssl"
	}];
}

+ (NSValueTransformer *)hookURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)insecureSSLJSONTransformer {
	return [MTLValueTransformer valueTransformerForName:OCTBooleanStringValueTransformerName];
}

@end
