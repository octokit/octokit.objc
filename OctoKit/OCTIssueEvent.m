//
//  OCTIssueEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueEvent.h"
#import "OCTIssue.h"

@implementation OCTIssueEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"issue": @"payload.issue",
		@"action": @"payload.action",
	}];
}

+ (NSValueTransformer *)issueJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTIssue.class];
}

+ (NSValueTransformer *)pullRequestJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTIssue.class];
}

+ (NSValueTransformer *)actionJSONTransformer {
	NSDictionary *actionsByName = @{
		@"opened": @(OCTIssueActionOpened),
		@"closed": @(OCTIssueActionClosed),
		@"reopened": @(OCTIssueActionReopened),
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
	return ([*actionPtr unsignedIntegerValue] != OCTIssueActionUnknown);
}

@end
