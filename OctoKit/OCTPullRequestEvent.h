//
//  OCTPullRequestEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"
#import "OCTIssueEvent.h"

@class OCTPullRequest;

// A pull request was opened or closed or somethin'.
@interface OCTPullRequestEvent : OCTEvent

// The pull request being modified.
@property (nonatomic, strong, readonly) OCTPullRequest *pullRequest;

// The action that took place upon the pull request.
@property (nonatomic, assign, readonly) OCTIssueAction action;

@end
