//
//  OCTMemberEvent.m
//  OctoKit
//
//  Created by Tyler Stromberg on 12/25/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTMemberEvent.h"

@implementation OCTMemberEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"memberName": @"payload.member.login",
		@"action": @"payload.action",
	}];
}

+ (NSValueTransformer *)actionJSONTransformer {
	NSDictionary *actionsByName = @{
		@"added": @(OCTMemberActionAdded),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *actionName) {
			return actionsByName[actionName];
		}
		reverseBlock:^(NSNumber *action) {
			return [actionsByName allKeysForObject:action].lastObject;
		}];
}

#pragma mark NSKeyValueCoding

- (BOOL)validateAction:(NSNumber **)actionPtr error:(NSError **)error {
	return ([*actionPtr unsignedIntegerValue] != OCTMemberActionUnknown);
}

@end
