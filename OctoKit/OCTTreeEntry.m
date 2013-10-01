//
//  OCTTreeEntry.m
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTTreeEntry.h"
#import "OCTCommitTreeEntry.h"
#import "OCTContentTreeEntry.h"
#import "OCTBlobTreeEntry.h"

@implementation OCTTreeEntry

#pragma mark Class Cluster

+ (NSDictionary *)contentClassesByType {
	return @{
		@"blob": OCTBlobTreeEntry.class,
		@"tree": OCTContentTreeEntry.class,
		@"commit": OCTCommitTreeEntry.class,
	};
}

#pragma mark MTLJSONSerializing

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	NSString *type = JSONDictionary[@"type"];
	NSAssert(type != nil, @"OCTTreeEntry JSON dictionary must contain a type string.");
	Class class = self.contentClassesByType[type];
	NSAssert(class != Nil, @"No known OCTTreeEntry class for the type '%@'.", type);
	return class;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"SHA": @"sha",
	}];
}

+ (NSValueTransformer *)typeJSONTransformer {
	NSDictionary *typeByName = @{
		@"blob": @(OCTTreeEntryTypeBlob),
		@"tree": @(OCTTreeEntryTypeTree),
		@"commit": @(OCTTreeEntryTypeCommit),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *typeName) {
			return typeByName[typeName];
		}
		reverseBlock:^(NSNumber *type) {
			return [typeByName allKeysForObject:type].lastObject;
		}];
}

+ (NSValueTransformer *)modeJSONTransformer {
	NSDictionary *typeByName = @{
		@"100644": @(OCTTreeEntryModeFile),
		@"100755": @(OCTTreeEntryModeExecutable),
		@"040000": @(OCTTreeEntryModeSubdirectory),
		@"160000": @(OCTTreeEntryModeSubmodule),
		@"120000": @(OCTTreeEntryModeSymlink),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *typeName) {
			return typeByName[typeName];
		}
		reverseBlock:^(NSNumber *type) {
			return [typeByName allKeysForObject:type].lastObject;
		}];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.SHA.hash;
}

- (BOOL)isEqual:(OCTTreeEntry *)entry {
	if (self == entry) return YES;
	if (![entry isKindOfClass:self.class]) return NO;

	return [entry.SHA isEqual:self.SHA];
}

@end
