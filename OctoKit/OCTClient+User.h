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

/// Fetches the full information for the specified `user`.
///
/// user - The specified user. This must not be nil.
///
/// Returns a signal which sends a new OCTUser.
- (RACSignal *)fetchUserInfoForUser:(OCTUser *)user;

/// Fetches the followers for the specified `user`.
///
/// user    - The specified user. This must not be nil.
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTUser objects.
- (RACSignal *)fetchFollowersForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage;

/// Fetches the following for the specified `user`.
///
/// user    - The specified user. This must not be nil.
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTUser objects.
- (RACSignal *)fetchFollowingForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage;

/// Check if the current `user` are following a user.
///
/// user - The specified user. This must not be nil.
///
/// Returns a signal, which will send a NSNumber valued @YES or @NO.
/// If the client is not `authenticated`, the signal will error immediately.
- (RACSignal *)doesFollowUser:(OCTUser *)user;

/// Follow the given `user`.
///
/// user - The user to follow. Cannot be nil.
///
/// Returns a signal, which will send completed on success. If the client
/// is not `authenticated`, the signal will error immediately.
- (RACSignal *)followUser:(OCTUser *)user;

/// Unfollow the given `user`.
///
/// user - The user to unfollow. Cannot be nil.
///
/// Returns a signal, which will send completed on success. If the client
/// is not `authenticated`, the signal will error immediately.
- (RACSignal *)unfollowUser:(OCTUser *)user;

@end
