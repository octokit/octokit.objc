//
//  OCTClient+Keys.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@interface OCTClient (Keys)

// Fetches the public keys for the current `user`.
//
// Returns a signal which sends zero or more OCTPublicKey objects. Unverified
// keys will only be included if the client is `authenticated`. If no `user` is
// set, the signal will error immediately.
- (RACSignal *)fetchPublicKeys;

// Adds a new public key to the current user's profile.
//
// Returns a signal which sends the new OCTPublicKey. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title;

@end
