//
//  OCTIssue.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTPullRequest;
@class OCTUser;

// An issue on a repository.
@interface OCTIssue : OCTObject

// The webpage URL for this issue.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this issue.
@property (nonatomic, copy, readonly) NSString *title;

// The body of this issue.
@property (nonatomic, copy, readonly) NSString *body;

// The pull request that is attached to (i.e., the same as) this issue, or nil
// if this issue does not have code attached.
@property (nonatomic, copy, readonly) OCTPullRequest *pullRequest;

// The API URL to get this issue's comments.
@property (nonatomic, copy, readonly) NSURL *commentsURL;

// The user who created this issue.
@property (nonatomic, strong, readonly) OCTUser *user;

@end
