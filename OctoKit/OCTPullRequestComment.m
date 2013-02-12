//
//  OCTPullRequestComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequestComment.h"
#import "OCTUser.h"

@implementation OCTPullRequestComment

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [super.externalRepresentationKeyPathsByPropertyKey mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"HTMLURL": @"_links.html.href",
		@"pullRequestAPIURL": @"_links.pull_request.href",
		@"body": @"body",
		@"commenter": @"user"
	}];

	return keys;
}

+ (NSValueTransformer *)HTMLURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pullRequestAPIURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)commenterTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTUser.class];
}

@end
