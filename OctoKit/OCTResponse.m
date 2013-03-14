//
//  OCTResponse.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTResponse.h"

@implementation OCTResponse

#pragma mark Lifecycle

- (id)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult {
	self = [super init];
	if (self == nil) return nil;

	_parsedResult = parsedResult;
	_etag = [response.allHeaderFields[@"ETag"] copy];

	_maximumRequestsPerHour = [response.allHeaderFields[@"X-RateLimit-Limit"] integerValue];
	_remainingRequests = [response.allHeaderFields[@"X-RateLimit-Remaining"] integerValue];

	NSString *intervalString = response.allHeaderFields[@"X-Poll-Interval"];
	if (intervalString.length > 0) {
		_pollInterval = @(intervalString.doubleValue);
	}

	return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.etag.hash;
}

- (BOOL)isEqual:(OCTResponse *)response {
	if (self == response) return YES;
	if (![response isKindOfClass:OCTResponse.class]) return NO;

	return [self.etag isEqual:response.etag] && [self.parsedResult isEqual:response.parsedResult];
}

@end
