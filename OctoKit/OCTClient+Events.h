//
//  OCTClient+Events.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@interface OCTClient (Events)

// Conditionally fetches events from the current user's activity stream. If
// the latest data matches `etag`, the call does not count toward the API rate
// limit.
//
// Returns a signal which will send zero or more OCTResponses (of OCTEvents) if
// new data was downloaded. Unrecognized events will be omitted from the result.
// On success, the signal will send completed regardless of whether there was
// new data. If no `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag;

/// Fetches the received events of the current user.
///
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTEvent objects.
- (RACSignal *)fetchUserReceivedEventsWithOffset:(NSUInteger)offset perPage:(NSUInteger)perPage;

/// Fetches the performed events for the specified `user`.
///
/// user    - The specified user. This must not be nil.
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTEvent objects.
- (RACSignal *)fetchPerformedEventsForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage;

@end
