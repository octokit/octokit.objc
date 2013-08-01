//
//  OCTResponse.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>

// Represents a parsed response from the GitHub API, along with any useful
// headers.
@interface OCTResponse : MTLModel

// The parsed MTLModel object corresponding to the API response.
@property (nonatomic, strong, readonly) id parsedResult;

// The etag uniquely identifying this response data.
@property (nonatomic, copy, readonly) NSString *etag;

// Set to any X-Poll-Interval header returned by the server, or nil if no such
// header was returned.
//
// This is used with the events and notifications APIs to support server-driven
// polling rates.
@property (nonatomic, copy, readonly) NSNumber *pollInterval;

// Set to the X-RateLimit-Limit header sent by the server, indicating how many
// unconditional requests the user is allowed to make per hour.
@property (nonatomic, assign, readonly) NSInteger maximumRequestsPerHour;

// Set to the X-RateLimit-Remaining header sent by the server, indicating how
// many remaining unconditional requests the user can make this hour (in server
// time).
@property (nonatomic, assign, readonly) NSInteger remainingRequests;

// Initializes the receiver with the headers from the given response, and the
// given parsed model object(s).
- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult;

@end
