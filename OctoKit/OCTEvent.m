//
//  OCTEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"
#import "OCTCommitCommentEvent.h"
#import "OCTIssueEvent.h"
#import "OCTIssueCommentEvent.h"
#import "OCTPullRequestEvent.h"
#import "OCTPullRequestCommentEvent.h"
#import "OCTPushEvent.h"
#import "OCTRefEvent.h"
#import "ISO8601DateFormatter.h"

static NSString * const OCTEventTypeKey = @"type";

@implementation OCTEvent

#pragma mark Class cluster

+ (NSDictionary *)eventClassesByType {
	return @{
		@"CommitCommentEvent": OCTCommitCommentEvent.class,
		@"CreateEvent": OCTRefEvent.class,
		@"DeleteEvent": OCTRefEvent.class,
		@"IssueCommentEvent": OCTIssueCommentEvent.class,
		@"IssuesEvent": OCTIssueEvent.class,
		@"PullRequestEvent": OCTPullRequestEvent.class,
		@"PullRequestReviewCommentEvent": OCTPullRequestCommentEvent.class,
		@"PushEvent": OCTPushEvent.class,
	};
}

#pragma mark Lifecycle

+ (id)modelWithExternalRepresentation:(NSDictionary *)externalRepresentation {
	Class eventClass = self.eventClassesByType[externalRepresentation[OCTEventTypeKey]];
	return [[eventClass alloc] initWithExternalRepresentation:externalRepresentation];
}

- (id)initWithExternalRepresentation:(NSDictionary *)externalRepresentation {
	Class eventClass = self.class.eventClassesByType[externalRepresentation[OCTEventTypeKey]];
	if (eventClass == nil) return nil;

	if ([self isKindOfClass:eventClass]) {
		return [super initWithExternalRepresentation:externalRepresentation];
	} else {
		return [eventClass modelWithExternalRepresentation:externalRepresentation];
	}
}

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"repositoryName": @"repo.name",
		@"actorLogin": @"actor.login",
		@"organizationLogin": @"org.login",
		@"date": @"created_at",
	}];

	return keys;
}

- (NSDictionary *)externalRepresentation {
	NSDictionary *representation = super.externalRepresentation;

	NSString *type = [[self.class.eventClassesByType allKeysForObject:self.class] lastObject];
	if (type != nil) {
		representation = [representation mtl_dictionaryByAddingEntriesFromDictionary:@{ OCTEventTypeKey: type }];
	}

	return representation;
}

+ (NSValueTransformer *)dateTransformer {
	// Don't support reverse transformation. This means that we'll never
	// serialize an NSString for this date (which is the Right Thing to do), but
	// we do have to check the type of the deserialized object.
	return [MTLValueTransformer transformerWithBlock:^ id (id date) {
		if (![date isKindOfClass:NSString.class]) return date;

		return [[[ISO8601DateFormatter alloc] init] dateFromString:date];
	}];
}

+ (NSValueTransformer *)objectIDTransformer {
	// The "id" field for events comes through as a string, which matches the
	// type of our objectID property.
	return nil;
}

@end
