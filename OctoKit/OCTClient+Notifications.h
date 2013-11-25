//
//  OCTClient+Notifications.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@interface OCTClient (Notifications)

// Conditionally fetch unread notifications for the user. If the latest data
// matches `etag`, the call does not count toward the API rate limit.
//
// etag        - An Etag from a previous request, used to avoid downloading
//               unnecessary data.
// includeRead - Whether to include notifications that have already been read.
// since       - If not nil, only notifications updated after this date will be
//               included.
//
// Returns a signal which will zero or more OCTResponses (of OCTNotifications)
// if new data was downloaded. On success, the signal will send completed
// regardless of whether there was new data. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)fetchNotificationsNotMatchingEtag:(NSString *)etag includeReadNotifications:(BOOL)includeRead updatedSince:(NSDate *)since;

// Mark a notification thread as having been read.
//
// threadURL - The API URL of the thread to mark as read. Cannot be nil.
//
// Returns a signal which will send completed on success. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)markNotificationThreadAsReadAtURL:(NSURL *)threadURL;

// Mutes all further notifications from a thread.
//
// threadURL - The API URL of the thread to mute. Cannot be nil.
//
// Returns a signal which will send completed on success. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)muteNotificationThreadAtURL:(NSURL *)threadURL;

@end
