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
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTGist

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"creationDate": @"created_at",
		@"HTMLURL": @"html_url",
	}];
}

+ (NSValueTransformer *)filesJSONTransformer {
	NSValueTransformer *dictionaryTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTGistFile.class];

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSDictionary *fileDictionaries) {
		if (![fileDictionaries isKindOfClass:NSDictionary.class]) return nil;

		NSMutableDictionary *files = [[NSMutableDictionary alloc] initWithCapacity:fileDictionaries.count];
		[fileDictionaries enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSDictionary *fileDictionary, BOOL *stop) {
			OCTGistFile *file = [dictionaryTransformer transformedValue:fileDictionary];
			if (file != nil) files[filename] = file;
		}];

		return files;
	} reverseBlock:^ id (NSDictionary *files) {
		if (![files isKindOfClass:NSDictionary.class]) return nil;

		NSMutableDictionary *fileDictionaries = [[NSMutableDictionary alloc] initWithCapacity:files.count];
		for (NSString *filename in fileDictionaries) {
			OCTGistFile *file = fileDictionaries[filename];
			NSDictionary *fileDictionary = [dictionaryTransformer reverseTransformedValue:file];
			if (fileDictionary == nil) return nil;
			
			fileDictionaries[filename] = fileDictionary;
		}

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

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end

@interface OCTGistEdit ()

// A combination of the information in `filesToModify`, `filesToAdd`, and
// `filenamesToDelete`, used for easy JSON serialization.
//
// This dictionary contains OCTGistFileEdits keyed by filename. Deleted
// filenames will have an NSNull value.
@property (atomic, copy, readonly) NSDictionary *fileChanges;

@end

@implementation OCTGistEdit

#pragma mark Properties

- (NSDictionary *)fileChanges {
	NSMutableDictionary *edits = [self.filesToModify mutableCopy] ?: [NSMutableDictionary dictionary];

	for (OCTGistFileEdit *edit in self.filesToAdd) {
		edits[edit.filename] = edit;
	}

	for (NSString *filename in self.filenamesToDelete) {
		edits[filename] = NSNull.null;
	}

	return edits;
}

+ (NSSet *)propertyKeys {
	return [NSSet setWithObjects:@keypath(OCTGistEdit.new, fileChanges), @keypath(OCTGistEdit.new, gistDescription), @keypath(OCTGistEdit.new, publicGist), nil];
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"fileChanges": @"files",
		@"publicGist": @"public",
		@"gistDescription": @"description",
	};
}

+ (NSValueTransformer *)fileChangesJSONTransformer {
	NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTGistFileEdit.class];

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSDictionary *files) {
		if (![files isKindOfClass:NSDictionary.class]) return nil;

		NSMutableDictionary *fileChanges = [NSMutableDictionary dictionaryWithCapacity:files.count];
		for (NSString *filename in files) {
			NSDictionary *change = files[filename];
			if ([change isEqual:NSNull.null]) {
				fileChanges[filename] = NSNull.null;
				continue;
			}

			OCTGistFileEdit *edit = [transformer transformedValue:change];
			if (edit == nil) return nil;

			fileChanges[filename] = edit;
		}

		return fileChanges;
	} reverseBlock:^ id (NSDictionary *fileChanges) {
		if (![fileChanges isKindOfClass:NSDictionary.class]) return nil;

		NSMutableDictionary *files = [NSMutableDictionary dictionaryWithCapacity:fileChanges.count];
		[fileChanges enumerateKeysAndObjectsUsingBlock:^(NSString *filename, OCTGistFileEdit *edit, BOOL *stop) {
			if ([edit isEqual:NSNull.null]) {
				files[filename] = NSNull.null;
				return;
			}

			NSDictionary *changes = [transformer reverseTransformedValue:edit];
			if (changes == nil) return;

			files[filename] = changes;
		}];

		return files;
	}];
}

+ (NSValueTransformer *)publicGistJSONTransformer {
	return [MTLValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
