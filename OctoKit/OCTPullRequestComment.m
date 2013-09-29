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

@synthesize path = _path;
@synthesize position = _position;
@synthesize commitSHA = _commitSHA;

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"pullRequestAPIURL": @"_links.pull_request.href",
		@"commenterLogin": @"user.login",
		@"commitSHA": @"commit_id",
		@"originalCommitSHA": @"original_commit_id",
		@"originalPosition": @"original_position",
		@"diffHunk": @"diff_hunk"
	}];
}

+ (NSValueTransformer *)pullRequestAPIURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
