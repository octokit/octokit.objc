//
//  OCTEvent.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"
#import "OCTCommitCommentEvent.h"
#import "OCTForkEvent.h"
#import "OCTIssueEvent.h"
#import "OCTIssueCommentEvent.h"
#import "OCTMemberEvent.h"
#import "OCTPublicEvent.h"
#import "OCTPullRequestEvent.h"
#import "OCTPullRequestCommentEvent.h"
#import "OCTPushEvent.h"
#import "OCTRefEvent.h"
#import "OCTWatchEvent.h"

@interface OCTEvent ()

// The event type of the receiver.
@property (nonatomic, copy, readonly) NSString *type;

@end

@implementation OCTEvent

#pragma mark Class cluster

+ (NSDictionary *)eventClassesByType {
	return @{
		@"CommitCommentEvent": OCTCommitCommentEvent.class,
		@"CreateEvent": OCTRefEvent.class,
		@"DeleteEvent": OCTRefEvent.class,
		@"ForkEvent": OCTForkEvent.class,
		@"IssueCommentEvent": OCTIssueCommentEvent.class,
		@"IssuesEvent": OCTIssueEvent.class,
		@"MemberEvent": OCTMemberEvent.class,
		@"PublicEvent": OCTPublicEvent.class,
		@"PullRequestEvent": OCTPullRequestEvent.class,
		@"PullRequestReviewCommentEvent": OCTPullRequestCommentEvent.class,
		@"PushEvent": OCTPushEvent.class,
		@"WatchEvent": OCTWatchEvent.class
	};
}

#pragma mark MTLJSONSerializing

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	return self.eventClassesByType[JSONDictionary[@"type"]];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"repositoryName": @"repo.name",
		@"actorLogin": @"actor.login",
		@"actorAvatarURL": @"actor.avatar_url",
		@"organizationLogin": @"org.login",
		@"date": @"created_at",
	}];
}

+ (NSValueTransformer *)dateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)objectIDJSONTransformer {
	// The "id" field for events comes through as a string, which matches the
	// type of our objectID property.
	return nil;
}

+ (NSValueTransformer *)actorAvatarURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
