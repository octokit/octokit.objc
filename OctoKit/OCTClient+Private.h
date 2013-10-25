//
//  OCTClient+Private.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@interface OCTClient ()

// Opens the specified URL in its preferred application.
//
// Returns whether the URL was opened successfully.
+ (BOOL)openURL:(NSURL *)URL;

// Launches the default web browser to the sign in page for the given server.
//
// server          - The server that the user should log in to. This must not be
//                   nil.
// scopes          - The scopes to request access to. These values can be
//                   bitwise OR'd together to request multiple scopes.
//
// Returns a signal that sends a temporary OAuth code when
// +completeSignInWithCallbackURL: is invoked with a matching callback URL, then
// completes. If any error occurs opening the web browser, it will be sent on
// the returned signal.
+ (RACSignal *)authorizeWithServerUsingWebBrowser:(OCTServer *)server scopes:(OCTClientAuthorizationScopes)scopes;

@end
