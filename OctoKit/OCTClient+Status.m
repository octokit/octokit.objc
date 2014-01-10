//
//  OCTClient+Status.m
//  OctoKit
//
//  Created by Jackson Harper on 1/10/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTStatus.h"
#import "OCTClient+Status.h"

@implementation OCTClient (Status)

- (RACSignal *)fetchStatusesForReference:(NSString *)reference inRepository:(OCTRepository *)repository
{
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/statuses/%@", repository.ownerLogin, repository.name, reference];

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTStatus.class] oct_parsedResults];
}

@end
