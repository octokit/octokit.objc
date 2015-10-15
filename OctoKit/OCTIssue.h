//
//  OCTIssue.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

typedef NS_ENUM(NSInteger, OCTIssueState) {
	OCTIssueStateOpen,
	OCTIssueStateClosed,
};

@class OCTPullRequest;

// An issue on a repository.
@interface OCTIssue : OCTObject

// The URL for this issue.
@property (nonatomic, copy, readonly) NSURL *URL;

// The webpage URL for this issue.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this issue.
@property (nonatomic, copy, readonly) NSString *title;

// The pull request that is attached to (i.e., the same as) this issue, or nil
// if this issue does not have code attached.
@property (nonatomic, copy, readonly) OCTPullRequest *pullRequest;

/// The state of the issue.
@property (nonatomic, assign, readonly) OCTIssueState state;

/// The issue number.
@property (nonatomic, copy, readonly) NSString *number;

@end
