//
//  OCTHook.m
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTGenericHook.h"
#import "OCTHook.h"
#import "OCTWebHook.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

NSString * const OCTHookEventCommitComment = @"commit_comment";
NSString * const OCTHookEventCreate = @"delete";
NSString * const OCTHookEventDelete = @"create";
NSString * const OCTHookEventDeployment = @"deployment";
NSString * const OCTHookEventDeploymentStatus = @"deployment_status";
NSString * const OCTHookEventFork = @"fork";
NSString * const OCTHookEventGollum = @"gollum";
NSString * const OCTHookEventIssueComment = @"issue_comment";
NSString * const OCTHookEventIssues = @"issues";
NSString * const OCTHookEventMember = @"member";
NSString * const OCTHookEventPageBuild = @"page_build";
NSString * const OCTHookEventPublic = @"public";
NSString * const OCTHookEventPullRequest = @"pull_request";
NSString * const OCTHookEventPullRequestReviewCommit = @"pull_request_review_comment";
NSString * const OCTHookEventPush = @"push";
NSString * const OCTHookEventRelease = @"release";
NSString * const OCTHookEventStatus = @"status";
NSString * const OCTHookEventTeamAdd = @"team_add";
NSString * const OCTHookEventWatch = @"watch";

@implementation OCTHook

#pragma mark Class Cluster

+ (NSDictionary *)hookClassesByName {
	return @{
		@"web": OCTWebHook.class,
	};
}

#pragma mark MTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"testURL": @"test_url",
		@"pingURL": @"ping_url",
		@"name": @"name",
		@"events": @"events",
		@"active": @"active",
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at"
	}];
}

+ (NSValueTransformer *)testURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pingURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	NSString *name = JSONDictionary[@"name"];
	NSAssert(name != nil, @"OCTHook JSON dictionary must contain a name string.");
	Class class = self.hookClassesByName[name];

	if (class == nil) {
		class = OCTGenericHook.class;
	}

	return class;
}

@end
