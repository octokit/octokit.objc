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

- (RACSignal *)searchRepositoriesWithQuery:(NSString *)query sort:(NSString *)sort order:(NSString *)order {
	NSParameterAssert(query.length > 0);
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"q"] = query;
	
	if (sort.length > 0) parameters[@"sort"] = sort;
	if (order.length > 0) parameters[@"order"] = order;
	
	NSURLRequest *request = [self requestWithMethod:@"GET" path:@"/search/repositories" parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepositoriesSearchResult.class fetchAllPages:NO] oct_parsedResults];
}

@end
