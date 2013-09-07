//
//  OCTPullRequestEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"
#import "OCTIssueEvent.h"

// The type of action performed on an issue or pull request.
//
// OCTPullRequestActionUnknown  - An unknown action occurred. PullRequest events
//								will never be initialized with this value -- they
//								will simply fail to be created.
// OCTPullRequestActionOpened      - The pull request was opened.
// OCTPullRequestActionClosed      - The pull request was closed.
// OCTPullRequestActionReopened    - The pull request was reopened.
// OCTPullRequestActionSynchronize - The pull request was syncronized.
typedef enum : NSUInteger {
    OCTPullRequestActionUnknown = 0,
    OCTPullRequestActionOpened,
    OCTPullRequestActionClosed,
    OCTPullRequestActionReopened,
	OCTPullRequestActionSynchronize,
} OCTPullRequestAction;

@class OCTPullRequest;

// A pull request was opened or closed or somethin'.
@interface OCTPullRequestEvent : OCTEvent

// The pull request being modified.
@property (nonatomic, strong, readonly) OCTPullRequest *pullRequest;

// The action that took place upon the pull request.
@property (nonatomic, assign, readonly) OCTPullRequestAction action;

@end
