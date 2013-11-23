//
//  OCTClient+Private.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

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

@end
