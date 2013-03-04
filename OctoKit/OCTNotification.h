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
typedef enum : NSUInteger {
	// An issue notification.
	OCTNotificationTypeIssue,

	// A pull request notification.
	OCTNotificationTypePullRequest,

	// A commit comment notification.
	OCTNotificationTypeCommit,
} OCTNotificationType;

// A notification of some type of activity.
@interface OCTNotification : OCTObject

// The title of the notification.
@property (nonatomic, readonly, copy) NSString *title;

// The URL to the thread.
@property (nonatomic, readonly, copy) NSURL *threadURL;

// The URL to the subject.
@property (nonatomic, readonly, copy) NSURL *subjectURL;

// The notification type.
@property (nonatomic, readonly, assign) OCTNotificationType type;

// The repository to which the notification belongs.
@property (nonatomic, readonly, strong) OCTRepository *repository;

// The date on which the notification was last updated.
@property (nonatomic, readonly, strong) NSDate *lastUpdatedDate;

@end
