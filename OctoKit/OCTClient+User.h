//
//  OCTClient+User.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@interface OCTClient (User)

// Fetches the full information of the current `user`.
//
// Returns a signal which sends a new OCTUser. The user may contain different
// levels of information depending on whether the client is `authenticated` or
// not. If no `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserInfo;

// Fetches the repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserRepositories;

// Fetches the starred repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserStarredRepositories;

// Creates a repository under the user's account.
//
// Returns a signal which sends the new OCTRepository. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate;

@end
