//
//  OCTGist.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-07-31.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTGist.h"
#import "OCTGistFile.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTGist

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"rawURL": @"raw_url",
		@"creationDate": @"created_at",
	}];
}

+ (NSValueTransformer *)filesJSONTransformer {
	NSValueTransformer *dictionaryTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTGistFile.class];

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *fileDictionaries) {
		NSMutableDictionary *files = [[NSMutableDictionary alloc] initWithCapacity:fileDictionaries.count];
		[fileDictionaries enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSDictionary *fileDictionary, BOOL *stop) {
			OCTGistFile *file = [dictionaryTransformer transformedValue:fileDictionary];
			if (file != nil) files[filename] = file;
		}];

		return files;
	} reverseBlock:^(NSDictionary *files) {
		NSMutableDictionary *fileDictionaries = [[NSMutableDictionary alloc] initWithCapacity:files.count];
		[files enumerateKeysAndObjectsUsingBlock:^(NSString *filename, OCTGistFile *file, BOOL *stop) {
			NSDictionary *fileDictionary = [dictionaryTransformer reverseTransformedValue:file];
			if (fileDictionary != nil) fileDictionaries[filename] = fileDictionary;
		}];

		return fileDictionaries;
	}];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

@end
