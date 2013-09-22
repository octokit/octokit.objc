//
//  OCTPullRequest.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

// The state of the pull request. open or closed.
//
// OCTPullRequestStateOpen   - The pull request is open.
// OCTPullRequestStateClosed - The pull request is closed.
typedef enum : NSUInteger {
    OCTPullRequestStateOpen,
    OCTPullRequestStateClosed
} OCTPullRequestState;

// A pull request on a repository.
@interface OCTPullRequest : OCTObject

// The api URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *URL;

// The webpage URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The diff URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *diffURL;

// The patch URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *patchURL;

// The issue URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *issueURL;

// The title of this pull request.
@property (nonatomic, copy, readonly) NSString *title;

// The body text for this pull request.
@property (nonatomic, copy, readonly) NSString *body;

// The user this pull request is assigned to.
@property (nonatomic, copy, readonly) OCTUser *assignee;

// The state of this pull request.
@property (nonatomic, readonly) OCTPullRequestState state;


@end
