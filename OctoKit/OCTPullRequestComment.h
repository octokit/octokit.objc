//
//  OCTPullRequestComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"
#import "OCTReviewComment.h"

// A single comment on a pull request.
@interface OCTPullRequestComment : OCTObject<OCTReviewComment>

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The API URL for the pull request upon which this comment appears.
@property (nonatomic, copy, readonly) NSURL *pullRequestAPIURL;

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

// The date at which the comment was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The date the comment was last updated. This will be equal to
// creationDate if the comment has not been updated.
@property (nonatomic, copy, readonly) NSDate *updatedDate;

// The relative path of the file being commented on.
@property (nonatomic, copy, readonly) NSString *path;

// The body of the pull request comment.
@property (nonatomic, copy, readonly) NSString *body;

// The current HEAD SHA of the pull request.
@property (nonatomic, copy, readonly) NSString *commitSHA;

// The HEAD SHA of the pull request when the comment was originally made.
@property (nonatomic, copy, readonly) NSString *originalCommitSHA;

// The line index in the pull request's current diff. The value will
// change if a subsequent commmit moves this line in the diff. If
// the line is removed the value will be nil.
@property (nonatomic, copy, readonly) NSNumber *position;

// This is the line index into the pull request's diff when the
// comment was originally made.
@property (nonatomic, copy, readonly) NSNumber *originalPosition;

@end
