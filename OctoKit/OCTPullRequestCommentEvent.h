//
//  OCTPullRequestCommentEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

@class OCTPullRequest;
@class OCTPullRequestComment;

// A user commented on a pull request.
@interface OCTPullRequestCommentEvent : OCTEvent

// The comment that was posted.
@property (nonatomic, strong, readonly) OCTPullRequestComment *comment;

// The pull request upon which the comment was posted.
//
// This is not set by the events API. It must be fetched and explicitly set in
// order to be used.
@property (atomic, strong) OCTPullRequest *pullRequest;

@end
