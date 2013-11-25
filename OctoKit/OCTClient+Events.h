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

@end
