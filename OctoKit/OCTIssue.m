//
//  OCTIssue.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssue.h"
#import "OCTPullRequest.h"
#import <ReactiveCocoa/EXTKeyPathCoding.h>

@interface OCTIssue ()

// The webpage URL for any attached pull request.
@property (nonatomic, copy, readonly) NSURL *pullRequestHTMLURL;

@end

@implementation OCTIssue

#pragma mark Properties

- (OCTPullRequest *)pullRequest {
	if (self.pullRequestHTMLURL == nil) return nil;

	// We don't have a "real" pull request model within the issue data, but we
	// have enough information to construct one.
	return [OCTPullRequest modelWithDictionary:@{
		@keypath(OCTPullRequest.new, objectID): self.objectID,
		@keypath(OCTPullRequest.new, HTMLURL): self.pullRequestHTMLURL,
		@keypath(OCTPullRequest.new, title): self.title,
	} error:NULL];
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"URL": @"url",
		@"HTMLURL": @"html_url",
		@"pullRequestHTMLURL": @"pull_request.html_url",
	}];
}

+ (NSValueTransformer *)URLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pullRequestHTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)numberJSONTransformer {
	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSNumber *num) {
			return num.stringValue;
		} reverseBlock:^ id (NSString *str) {
			if (str == nil) return nil;

			return [NSDecimalNumber decimalNumberWithString:str];
		}];
}

+ (NSValueTransformer *)stateJSONTransformer {
	NSDictionary *statesByName = @{
		@"open": @(OCTIssueStateOpen),
		@"closed": @(OCTIssueStateClosed),
	};

	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSString *stateName) {
			return statesByName[stateName];
		}
		reverseBlock:^(NSNumber *state) {
			return [statesByName allKeysForObject:state].lastObject;
		}];
}

@end
