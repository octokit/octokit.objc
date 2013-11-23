//
//  OCTClient+Gists.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTGist;
@class OCTGistEdit;

@interface OCTClient (Gists)

// Fetches all the gists for the current user.
//
// Returns a signal which will send zero or more OCTGists and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)fetchGists;

// Edits one or more files within a gist.
//
// edit - The changes to make to the gist. This must not be nil.
// gist - The gist to modify. This must not be nil.
//
// Returns a signal which will send the updated OCTGist and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)applyEdit:(OCTGistEdit *)edit toGist:(OCTGist *)gist;

// Creates a gist using the given changes.
//
// edit - The changes to use for creating the gist. This must not be nil.
//
// Returns a signal which will send the created OCTGist and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)createGistWithEdit:(OCTGistEdit *)edit;

@end
