//
//  OCTPullRequestComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequestComment.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTPullRequestComment

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"HTMLURL": @"_links.html.href",
		@"pullRequestAPIURL": @"_links.pull_request.href",
		@"commenterLogin": @"user.login",
		@"commitSHA": @"commit_id",
		@"originalCommitSHA": @"original_commit_id",
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at",
		@"originalPosition": @"original_position"
	}];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pullRequestAPIURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

@end
