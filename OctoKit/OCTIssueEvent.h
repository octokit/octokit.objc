//
//  OCTIssueEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

@class OCTIssue;

// The type of action performed on an issue or pull request.
//
// OCTIssueActionUnknown  - An unknown action occurred. Issue events will
//                          never be initialized with this value -- they
//                          will simply fail to be created.
// OCTIssueActionOpened   - The issue or pull request was opened.
// OCTIssueActionClosed   - The issue or pull request was closed.
// OCTIssueActionReopened - The issue or pull request was reopened.
typedef enum : NSUInteger {
    OCTIssueActionUnknown = 0,
    OCTIssueActionOpened,
    OCTIssueActionClosed,
    OCTIssueActionReopened
} OCTIssueAction;

// An issue was opened or closed or somethin'.
@interface OCTIssueEvent : OCTEvent

// The issue being modified.
@property (nonatomic, strong, readonly) OCTIssue *issue;

// The action that took place upon the issue.
@property (nonatomic, assign, readonly) OCTIssueAction action;

@end
