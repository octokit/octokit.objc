//
//  OCTPullRequest.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// The state of the pull request. open or closed. Default is open.
//
// OCTPullRequestStateOpen  - The pull request is open.
// OCTPullRequestStateClosed   - The pull request is closed.
typedef enum : NSUInteger {
    OCTPullRequestStateOpen,
    OCTPullRequestStateClosed
} OCTPullRequestState;

// A pull request on a repository.
@interface OCTPullRequest : OCTObject

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

// The state of this pull request. open or closed. Default is open.
@property (nonatomic, readonly) OCTPullRequestState state;


@end
