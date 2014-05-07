//
//  OCTIssueComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueComment.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTIssueComment

@synthesize body = _body;
@synthesize commenterLogin = _commenterLogin;
@synthesize creationDate = _creationDate;
@synthesize updatedDate = _updatedDate;

#pragma mark MTLJSONSerializing

+ (NSSet *)propertyKeys {
	return [super.propertyKeys setByAddingObjectsFromArray:@[
		// OCTComment
		@"body",
		@"commenterLogin",
		@"creationDate",
		@"updatedDate",
	]];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"HTMLURL": @"html_url",
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
