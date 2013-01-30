//
//  OCTResponse.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Represents a parsed response from the GitHub API, along with any useful
// headers.
//
@interface OCTResponse : NSObject <NSCopying>

// The parsed MTLModel object corresponding to the API response.
@property (nonatomic, strong, readonly) id parsedResult;

// The etag uniquely identifying this response data.
@property (nonatomic, copy, readonly) NSString *etag;

// Set to any X-Poll-Interval header returned by the server, or nil if no such
// header was returned.
//
// This is currently only meaningful for the events API.
@property (nonatomic, copy, readonly) NSNumber *pollInterval;

// Initializes the receiver with the headers from the given response, and the
// given parsed model object(s).
- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult;

@end
