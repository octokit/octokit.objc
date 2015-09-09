//
//  OCTClient+Private.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

// The version of the GitHub API to use.
extern NSString * const OCTClientAPIVersion;

@interface OCTClient ()

// An error indicating that a request required a valid user, but no `user`
// property was set.
+ (NSError *)userRequiredError;

// An error indicating that a request required authentication, but the client
// was not created with a token.
+ (NSError *)authenticationRequiredError;

// An error indicating that the current server version does not support our
// request.
+ (NSError *)unsupportedVersionError;

// Enqueues a request to fetch information about the current user by accessing
// a path relative to the user object.
//
// method       - The HTTP method to use.
// relativePath - The path to fetch, relative to the user object. For example,
//                to request `user/orgs` or `users/:user/orgs`, simply pass in
//                `/orgs`. This may not be nil, and must either start with a '/'
//                or be an empty string.
// parameters   - HTTP parameters to encode and send with the request.
// resultClass  - The class that response data should be returned as.
//
// Returns a signal which will send an instance of `resultClass` for each parsed
// JSON object, then complete. If no `user` is set on the receiver, the signal
// will error immediately.
- (RACSignal *)enqueueUserRequestWithMethod:(NSString *)method relativePath:(NSString *)relativePath parameters:(NSDictionary *)parameters resultClass:(Class)resultClass;

// Enqueues a request that will not automatically parse results.
//
// request       - The previously constructed URL request for the endpoint.
// fetchAllPages - Whether to fetch all pages of the given endpoint.
//
// Returns a signal which will send tuples for each page, containing the
// `NSHTTPURLResponse` and response object (the type of which will be determined
// by AFNetworking), then complete. If an error occurs at any point, the
// returned signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request fetchAllPages:(BOOL)fetchAllPages;

// Enqueues a request to be sent to the server.
//
// request       - The previously constructed URL request for the endpoint.
// resultClass   - A subclass of OCTObject that the response data should be
//                 returned as. If this is nil, NSDictionary will be used for
//                 each object in the JSON received.
// fetchAllPages - Whether to fetch all pages of the given endpoint.
//
// Returns a signal which will send an instance of `OCTResponse` for each parsed
// JSON object, then complete. If an error occurs at any point, the returned
// signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass fetchAllPages:(BOOL)fetchAllPages;

// Opens the specified URL in its preferred application.
//
// Returns whether the URL was opened successfully.
+ (BOOL)openURL:(NSURL *)URL;

// Launches the default web browser to the sign in page for the given server.
//
// server - The server that the user should sign in to. This must not be
//          nil.
// scopes - The scopes to request access to. These values can be
//          bitwise OR'd together to request multiple scopes.
//
// Returns a signal that sends a temporary OAuth code when
// +completeSignInWithCallbackURL: is invoked with a matching callback URL, then
// completes. If any error occurs opening the web browser, it will be sent on
// the returned signal.
+ (RACSignal *)authorizeWithServerUsingWebBrowser:(OCTServer *)server scopes:(OCTClientAuthorizationScopes)scopes;

// Converts the provided OCTServer into an OCTServer for the same
// host and path but using HTTPS instead of HTTP.
//
// server - The OCTServer to convert to using HTTPS.
//
// Returns an OCTServer that uses HTTPS.
+ (OCTServer *)HTTPSEnterpriseServerWithServer:(OCTServer *)server;

/// Retrieves the valid perPage according to the original perPage.
///
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns the valid perPage.
- (NSUInteger)perPageWithPerPage:(NSUInteger)perPage;

/// Retrieves the corresponding page according to the offset and the valid perPage.
///
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns the corresponding page.
- (NSUInteger)pageWithOffset:(NSUInteger)offset perPage:(NSUInteger)perPage;

/// Retrieves the corresponding pageOffset according to the offset and the valid perPage.
///
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns the corresponding pageOffset.
- (NSUInteger)pageOffsetWithOffset:(NSUInteger)offset perPage:(NSUInteger)perPage;

@end
