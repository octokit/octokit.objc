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

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"pullRequest": @"payload.pull_request",
		@"action": @"payload.action",
	}];

	return keys;
}

+ (NSValueTransformer *)pullRequestTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTPullRequest.class];
}

+ (NSValueTransformer *)actionTransformer {
	NSDictionary *actionsByName = @{
		@"opened": @(OCTIssueActionOpened),
		@"closed": @(OCTIssueActionClosed),
		@"reopened": @(OCTIssueActionReopened),
	};

	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *actionName) {
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
