//
//  OCTResponse.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTResponse.h"
#import <ReactiveCocoa/EXTKeyPathCoding.h>

@interface OCTResponse ()

@property (nonatomic, copy, readonly) NSHTTPURLResponse *HTTPURLResponse;

@end

@implementation OCTResponse

#pragma mark Properties

- (NSString *)etag {
	return self.HTTPURLResponse.allHeaderFields[@"ETag"];
}

- (NSInteger)statusCode {
	return self.HTTPURLResponse.statusCode;
}

- (NSInteger)maximumRequestsPerHour {
	return [self.HTTPURLResponse.allHeaderFields[@"X-RateLimit-Limit"] integerValue];
}

- (NSInteger)remainingRequests {
	return [self.HTTPURLResponse.allHeaderFields[@"X-RateLimit-Remaining"] integerValue];
}

- (NSNumber *)pollInterval {
	NSString *intervalString = self.HTTPURLResponse.allHeaderFields[@"X-Poll-Interval"];
	return (intervalString.length > 0 ? @(intervalString.doubleValue) : nil);
}

#pragma mark Lifecycle

- (id)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult {
	return [super initWithDictionary:@{
		@keypath(self.parsedResult): parsedResult ?: NSNull.null,
		@keypath(self.HTTPURLResponse): [response copy] ?: NSNull.null,
	} error:NULL];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.HTTPURLResponse.hash;
}

@end
