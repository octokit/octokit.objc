//
//  OCTRefEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTRefEvent.h"

@implementation OCTRefEvent

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"eventType": @"type",
		@"refType": @"payload.ref_type",
		@"refName": @"payload.ref",
	}];

	return keys;
}

+ (NSValueTransformer *)refTypeTransformer {
	NSDictionary *typesByName = @{
		@"branch": @(OCTRefTypeBranch),
		@"tag": @(OCTRefTypeTag),
	};

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *typeName) {
			return typesByName[typeName];
		}
		reverseBlock:^(NSNumber *type) {
			return [typesByName allKeysForObject:type].lastObject;
		}];
}

+ (NSValueTransformer *)eventTypeTransformer {
	NSDictionary *typesByName = @{
		@"CreateEvent": @(OCTRefEventCreated),
		@"DeleteEvent": @(OCTRefEventDeleted),
	};

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *typeName) {
			return typesByName[typeName];
		}
		reverseBlock:^(NSNumber *type) {
			return [typesByName allKeysForObject:type].lastObject;
		}];
}

#pragma mark NSKeyValueCoding

- (BOOL)validateEventType:(NSNumber **)eventTypePtr error:(NSError **)error {
	return ([*eventTypePtr unsignedIntegerValue] != OCTRefEventUnknown);
}

- (BOOL)validateRefType:(NSNumber **)refTypePtr error:(NSError **)error {
	return ([*refTypePtr unsignedIntegerValue] != OCTRefTypeUnknown);
}

@end
