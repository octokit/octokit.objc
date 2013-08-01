//
//  OCTResponse.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTResponse.h"
#import "EXTKeyPathCoding.h"

@implementation OCTResponse

#pragma mark Lifecycle

- (id)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult {
	NSString *intervalString = response.allHeaderFields[@"X-Poll-Interval"];

	return [super initWithDictionary:@{
		@keypath(self.parsedResult): parsedResult ?: NSNull.null,
		@keypath(self.etag): [response.allHeaderFields[@"ETag"] copy] ?: NSNull.null,
		@keypath(self.maximumRequestsPerHour): @([response.allHeaderFields[@"X-RateLimit-Limit"] integerValue]),
		@keypath(self.remainingRequests): @([response.allHeaderFields[@"X-RateLimit-Remaining"] integerValue]),
		@keypath(self.pollInterval): (intervalString.length > 0 ? @(intervalString.doubleValue) : NSNull.null),
	} error:NULL];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.etag.hash;
}

@end
