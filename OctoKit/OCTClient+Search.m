//
//  OCTClient+Search.m
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import "OCTClient+Search.h"
#import "OCTClient+Private.h"

@implementation OCTClient (Search)

- (RACSignal *)searchRepositoriesWithQuery:(NSString *)query orderBy:(NSString *)orderBy ascending:(BOOL)ascending {
	NSParameterAssert(query.length > 0);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"q"] = query;
	
	if (orderBy.length > 0) parameters[@"sort"] = orderBy;
	parameters[@"order"] = ascending ? @"asc" : @"desc";
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:@"/search/repositories" parameters:parameters notMatchingEtag:nil];
	[request addValue:@"application/vnd.github.v3.text-match+json" forHTTPHeaderField:@"Accept"];
	
	return [[self enqueueRequest:request resultClass:OCTRepositoriesSearchResult.class fetchAllPages:NO] oct_parsedResults];
}

@end
