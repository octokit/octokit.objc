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

			// FIXME
			if (file != nil) files[filename] = file;
		}];

		return files;
	} reverseBlock:^(NSDictionary *files) {
		NSMutableDictionary *fileDictionaries = [[NSMutableDictionary alloc] initWithCapacity:files.count];
		[files enumerateKeysAndObjectsUsingBlock:^(NSString *filename, OCTGistFile *file, BOOL *stop) {
			NSDictionary *fileDictionary = [dictionaryTransformer reverseTransformedValue:file];

			// FIXME
			if (fileDictionary != nil) fileDictionaries[filename] = fileDictionary;
		}];

		return fileDictionaries;
	}];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)objectIDJSONTransformer {
	// The "id" field for gists comes through as a string, which matches the
	// type of our objectID property.
	return nil;
}

@end

@implementation OCTGistEdit

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"fileChanges": @"files",
	}];
}

+ (NSValueTransformer *)fileChangesJSONTransformer {
	NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTGistFileEdit.class];

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *files) {
		NSMutableDictionary *fileChanges = [NSMutableDictionary dictionaryWithCapacity:files.count];
		[files enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSDictionary *change, BOOL *stop) {
			if ([change isEqual:NSNull.null]) {
				fileChanges[filename] = NSNull.null;
				return;
			}

			OCTGistFileEdit *edit = [transformer transformedValue:change];
			
			// FIXME
			if (edit == nil) return;

			fileChanges[filename] = edit;
		}];

		return fileChanges;
	} reverseBlock:^(NSDictionary *fileChanges) {
		NSMutableDictionary *files = [NSMutableDictionary dictionaryWithCapacity:fileChanges.count];
		[fileChanges enumerateKeysAndObjectsUsingBlock:^(NSString *filename, OCTGistFileEdit *edit, BOOL *stop) {
			if ([edit isEqual:NSNull.null]) {
				files[filename] = NSNull.null;
				return;
			}

			NSDictionary *changes = [transformer reverseTransformedValue:edit];
			
			// FIXME
			if (changes == nil) return;

			files[filename] = changes;
		}];

		return files;
	}];
}

@end
