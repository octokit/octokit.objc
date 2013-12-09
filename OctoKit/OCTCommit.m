//
//  OCTCommit.m
//  OctoKit
//
//  Created by Jackson Harper on 8/8/13.
//  Copyright (c) 2013 SyntaxTree, Inc. All rights reserved.
//

#import "OCTCommit.h"

#import <OctoKit/OctoKit.h>


@implementation OCTCommit

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"SHA": @"sha",
		@"URL": @"url",
		@"HTMLURL": @"html_url",
		@"commentsURL": @"comments_url",
		@"authorDate": @"commit.author.date",
		@"commitDate": @"commit.committer.date",
		@"message": @"commit.message",
	}];
}

+ (NSValueTransformer *)URLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)commentsURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)authorJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTUser.class];
}

+ (NSValueTransformer *)committerJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTUser.class];
}

+ (NSValueTransformer *)commentsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:OCTCommitComment.class];
}

+ (NSValueTransformer *)authorDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)commitDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return [self.SHA hash];
}

- (BOOL)isEqual:(OCTCommit *)commit {
	if (self == commit) return YES;
	if (![commit isKindOfClass:self.class]) return NO;

	return [commit.SHA isEqual:self.SHA];
}

@end
