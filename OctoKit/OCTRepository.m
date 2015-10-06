//
//  OCTRepository.m
//  OctoKit
//
//  Created by Timothy Clem on 2/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTRepository.h"

#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

static NSString *const OCTRepositoryHTMLIssuesPath = @"issues";

@implementation OCTRepository

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"HTTPSURL": @"clone_url",
		@"SSHURL": @"ssh_url",
		@"gitURL": @"git_url",
		@"HTMLURL": @"html_url",
		@"ownerLogin": @"owner.login",
		@"ownerAvatarURL": @"owner.avatar_url",
		@"datePushed": @"pushed_at",
		@"dateCreated": @"created_at",
		@"dateUpdated": @"updated_at",
		@"watchersCount": @"watchers_count",
		@"forksCount": @"forks_count",
		@"stargazersCount": @"stargazers_count",
		@"openIssuesCount": @"open_issues_count",
		@"subscribersCount": @"subscribers_count",
		@"repoDescription": @"description",
		@"defaultBranch": @"default_branch",
		@"forkParent": @"parent",
		@"forkSource": @"source",
		@"textMatches": @"text_matches",
	}];
}

+ (NSValueTransformer *)HTTPSURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)gitURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)ownerAvatarURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)datePushedJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)dateCreatedJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)dateUpdatedJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)forkParentJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)forkSourceJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

#pragma mark Derived Properties

- (NSURL *)issuesHTMLURL {
	return [self.HTMLURL URLByAppendingPathComponent:OCTRepositoryHTMLIssuesPath];
}

#pragma mark Migration

+ (NSDictionary *)dictionaryValueFromArchivedExternalRepresentation:(NSDictionary *)externalRepresentation version:(NSUInteger)fromVersion {
	NSMutableDictionary *dictionaryValue = [[super dictionaryValueFromArchivedExternalRepresentation:externalRepresentation version:fromVersion] mutableCopy];

	// Although some of these keys match JSON key paths, the format of this
	// external representation is fixed (since it's always old data), thus the
	// hard-coding.
	dictionaryValue[@"name"] = externalRepresentation[@"name"];

	id owner = externalRepresentation[@"owner"];
	if ([owner isKindOfClass:NSString.class]) {
		dictionaryValue[@"ownerLogin"] = owner;
	} else if ([owner isKindOfClass:NSDictionary.class]) {
		dictionaryValue[@"ownerLogin"] = owner[@"login"];
	}

	dictionaryValue[@"language"] = externalRepresentation[@"language"] ?: NSNull.null;
	dictionaryValue[@"repoDescription"] = externalRepresentation[@"description"] ?: NSNull.null;
	dictionaryValue[@"private"] = externalRepresentation[@"private"] ?: @NO;
	dictionaryValue[@"fork"] = externalRepresentation[@"fork"] ?: @NO;
	dictionaryValue[@"datePushed"] = [self.datePushedJSONTransformer transformedValue:externalRepresentation[@"pushed_at"]] ?: NSNull.null;
	dictionaryValue[@"HTTPSURL"] = [self.HTTPSURLJSONTransformer transformedValue:externalRepresentation[@"clone_url"]] ?: NSNull.null;
	dictionaryValue[@"SSHURL"] = externalRepresentation[@"ssh_url"] ?: NSNull.null;
	dictionaryValue[@"gitURL"] = [self.gitURLJSONTransformer transformedValue:externalRepresentation[@"git_url"]] ?: NSNull.null;

	NSString *HTMLURLString = externalRepresentation[@"html_url"] ?: externalRepresentation[@"url"];
	dictionaryValue[@"HTMLURL"] = [self.HTMLURLJSONTransformer transformedValue:HTMLURLString] ?: NSNull.null;

	return dictionaryValue;
}

@end
