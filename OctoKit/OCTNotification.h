//
//  OCTNotification.h
//  OctoKit
//
//  Created by Josh Abernathy on 1/22/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTRepository;

// The type of the notification.
//
// OCTNotificationTypeUnknown     - An unknown type of notification.
// OCTNotificationTypeIssue       - A new issue, or a new comment on one.
// OCTNotificationTypePullRequest - A new pull request, or a new comment on one.
// OCTNotificationTypeCommit      - A new comment on a commit.
typedef enum : NSUInteger {
    OCTNotificationTypeUnknown,
	OCTNotificationTypeIssue,
	OCTNotificationTypePullRequest,
	OCTNotificationTypeCommit,
} OCTNotificationType;

// A notification of some type of activity.
@interface OCTNotification : OCTObject

// The title of the notification.
@property (nonatomic, readonly, copy) NSString *title;

// The API URL to the notification's thread.
@property (nonatomic, readonly, copy) NSURL *threadURL;

// The API URL to the subject that the notification was generated for (e.g., the
// issue or pull request).
@property (nonatomic, readonly, copy) NSURL *subjectURL;

// The API URL to the latest comment in the thread.
//
// If the notification does not represent a comment, this will be the same as
// the subjectURL.
@property (nonatomic, readonly, copy) NSURL *latestCommentURL;

// The notification type.
@property (nonatomic, readonly, assign) OCTNotificationType type;

// The repository to which the notification belongs.
@property (nonatomic, readonly, strong) OCTRepository *repository;

// The date on which the notification was last updated.
@property (nonatomic, readonly, strong) NSDate *lastUpdatedDate;

// Whether this notification has yet to be read.
@property (nonatomic, readonly, getter = isUnread) BOOL unread;

@end
