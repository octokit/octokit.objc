//
//  OCTRepository.m
//  OctoClient
//
//  Created by Timothy Clem on 2/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTRepository.h"
#import "ISO8601DateFormatter.h"

// Keys used in parsing and migration.
static NSString * const OCTRepositoryHTMLURLKey = @"html_url";
static NSString * const OCTRepositoryOwnerKey = @"owner";
static NSString * const OCTRepositoryLoginKey = @"login";

// 1.0 => 1.2.4: OCTRepositoryModelVersion = 0;
// 1.2.4 => current: OCTRepositoryModelVersion = 2;
static const NSUInteger OCTRepositoryModelVersion = 3;

@implementation OCTRepository

#pragma mark MTLModel

+ (NSUInteger)modelVersion {
	return OCTRepositoryModelVersion;
}

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
	// Don't support reverse transformation. This means that we'll never
	// serialize an NSString for this date (which is the Right Thing to do), but
	// we do have to check the type of the deserialized object.
	return [MTLValueTransformer transformerWithBlock:^ id (id date) {
		if (![date isKindOfClass:NSString.class]) return date;

		return [[[ISO8601DateFormatter alloc] init] dateFromString:date];
	}];
}

+ (NSDictionary *)migrateExternalRepresentation:(NSDictionary *)dictionary fromVersion:(NSUInteger)fromVersion {
	NSMutableDictionary *convertedDictionary = [[super migrateExternalRepresentation:dictionary fromVersion:fromVersion] mutableCopy];
	
	if (fromVersion < 3) {
		convertedDictionary[OCTRepositoryHTMLURLKey] = dictionary[@"url"] ?: NSNull.null;
		convertedDictionary[OCTRepositoryOwnerKey] = @{ OCTRepositoryLoginKey: (dictionary[@"owner"] ?: NSNull.null) };
	}
	
	return convertedDictionary;
}

@end
