//
//  OCTMilestone.m
//  OctoKit
//
//  Created by Toby Boudreaux on 6/10/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTMilestone.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTMilestone

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
			@"HTMLURL": @"html_url",
			@"objectID": @"number",
			@"dueOnDate": @"due_date",
			@"dateCreated": @"created_at",
			}];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}



@end
