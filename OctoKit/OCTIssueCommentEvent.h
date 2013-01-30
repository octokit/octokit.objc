//
//  OCTIssueCommentEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

@class OCTIssue;
@class OCTIssueComment;

// A user commented on an issue.
@interface OCTIssueCommentEvent : OCTEvent

// The comment that was posted.
@property (nonatomic, strong, readonly) OCTIssueComment *comment;

// The issue upon which the comment was posted.
@property (nonatomic, strong, readonly) OCTIssue *issue;

@end
