//
//  OCTPullRequestEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequestEvent.h"
#import "OCTPullRequest.h"

@implementation OCTPullRequestEvent

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"pullRequest": @"payload.pull_request",
		@"action": @"payload.action",
	}];
}

+ (NSValueTransformer *)pullRequestJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTPullRequest.class];
}

+ (NSValueTransformer *)actionJSONTransformer {
	NSDictionary *actionsByName = @{
		@"opened": @(OCTIssueActionOpened),
		@"closed": @(OCTIssueActionClosed),
		@"reopened": @(OCTIssueActionReopened),
		@"synchronized": @(OCTIssueActionSynchronized),
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
