//
//  OCTFeed.m
//  OctoKit
//
//  Created by Yorkie on 4/27/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTFeed.h"

@implementation OCTFeed

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"timelineURL": @"timeline_url",
		@"userURL": @"user_url",
		@"currentUserURL": @"current_user_url",
		@"currentUserPublicURL": @"current_user_public_url",
		@"currentUserActivityURL": @"current_user_actor_url",
		@"currentUserOrgURL": @"current_user_organization_url"
	}];
}

+ (NSValueTransformer *)timelineURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)currentUserURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)currentUserPublicURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)currentUserActorURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)currentUserOrgURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
