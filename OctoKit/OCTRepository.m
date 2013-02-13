//
//  OCTRepository.m
//  OctoKit
//
//  Created by Timothy Clem on 2/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTRepository.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

// Keys used in parsing and migration.
static NSString * const OCTRepositoryHTMLURLKey = @"html_url";
static NSString * const OCTRepositoryOwnerKey = @"owner";
static NSString * const OCTRepositoryLoginKey = @"login";

@implementation OCTRepository

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"HTTPSURL": @"clone_url",
		@"SSHURL": @"ssh_url",
		@"gitURL": @"git_url",
		@"HTMLURL": OCTRepositoryHTMLURLKey,
		@"ownerLogin": [OCTRepositoryOwnerKey stringByAppendingFormat:@".%@", OCTRepositoryLoginKey],
		@"datePushed": @"pushed_at",
		@"repoDescription": @"description",
	}];

	return keys;
}

+ (NSValueTransformer *)HTTPSURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)gitURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)datePushedTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

#pragma mark Migration

+ (NSDictionary *)dictionaryValueFromArchivedExternalRepresentation:(NSDictionary *)externalRepresentation version:(NSUInteger)fromVersion {
	NSMutableDictionary *dictionaryValue = [NSMutableDictionary dictionaryWithCapacity:externalRepresentation.count];

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

	dictionaryValue[@"repoDescription"] = externalRepresentation[@"description"] ?: NSNull.null;
	dictionaryValue[@"private"] = externalRepresentation[@"private"] ?: @NO;
	dictionaryValue[@"datePushed"] = [self.datePushedJSONTransformer transformedValue:externalRepresentation[@"pushed_at"]] ?: NSNull.null;
	dictionaryValue[@"HTTPSURL"] = [self.HTTPSURLJSONTransformer transformedValue:externalRepresentation[@"clone_url"]] ?: NSNull.null;
	dictionaryValue[@"SSHURL"] = externalRepresentation[@"ssh_url"] ?: NSNull.null;
	dictionaryValue[@"gitURL"] = [self.gitURLJSONTransformer transformedValue:externalRepresentation[@"git_url"]] ?: NSNull.null;

	NSString *HTMLURLString = externalRepresentation[@"html_url"] ?: externalRepresentation[@"url"];
	dictionaryValue[@"HTMLURL"] = [self.HTMLURLJSONTransformer transformedValue:HTMLURLString] ?: NSNull.null;

	return dictionaryValue;
}

@end
