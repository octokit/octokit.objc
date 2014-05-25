//
//  OCTServer.h
//  OctoKit
//
//  Created by Alan Rogers on 18/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>

// The default URL scheme to use for Enterprise URLs, if none is explicitly
// known or specified.
extern NSString * const OCTServerDefaultEnterpriseScheme;

// The HTTPS URL scheme to use for Enterprise URLs.
extern NSString * const OCTServerHTTPSEnterpriseScheme;

// Represents a GitHub server instance
// (ie. github.com or an Enterprise instance)
@interface OCTServer : MTLModel

// Returns YES if this is an Enterprise instance
@property (nonatomic, assign, getter = isEnterprise, readonly) BOOL enterprise;

// The base URL to the instance associated with this server
@property (nonatomic, copy, readonly) NSURL *baseURL;

// The base URL to the API we should use for requests to this server
// (i.e., Enterprise or github.com).
//
// This URL is constructed from the baseURL.
@property (nonatomic, copy, readonly) NSURL *APIEndpoint;

// The base URL to the website for the instance (the
// Enterprise landing page or github.com).
//
// This URL is constructed from the baseURL.
@property (nonatomic, copy, readonly) NSURL *baseWebURL;

// Returns the github.com server instance
+ (instancetype)dotComServer;

// Returns either the Enterprise instance for a given base URL, or +dotComServer
// if `baseURL` is nil.
+ (instancetype)serverWithBaseURL:(NSURL *)baseURL;

@end
