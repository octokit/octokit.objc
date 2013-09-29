//
//  OCTPullRequestComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"
#import "OCTIssueComment.h"
#import "OCTReviewComment.h"

// A single comment on a pull request.
@interface OCTPullRequestComment : OCTIssueComment <OCTReviewComment>

// The API URL for the pull request upon which this comment appears.
@property (nonatomic, copy, readonly) NSURL *pullRequestAPIURL;

// The HEAD SHA of the pull request when the comment was originally made.
@property (nonatomic, copy, readonly) NSString *originalCommitSHA;

// This is the line index into the pull request's diff when the
// comment was originally made.
@property (nonatomic, copy, readonly) NSNumber *originalPosition;

// The hunk in the diff that this comment originally refered to.
@property (nonatomic, copy, readonly) NSString *diffHunk;

@end
