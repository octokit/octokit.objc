//
//  OCTCommitComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTCommitComment.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTCommitComment

@synthesize body = _body;
@synthesize path = _path;
@synthesize position = _position;
@synthesize commitSHA = _commitSHA;
@synthesize commenterLogin = _commenterLogin;
@synthesize creationDate = _creationDate;
@synthesize updatedDate = _updatedDate;

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"HTMLURL": @"html_url",
		@"commitSHA": @"commit_id",
		@"commenterLogin": @"user.login",
		@"creationDate": @"created_at",
		@"updatedDate": @"updated_at",
	}];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
	return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

@end
