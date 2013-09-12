//
//  OCTCommitComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A single comment on a commit.
@interface OCTCommitComment : OCTObject

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The SHA of the commit being commented upon.
@property (nonatomic, copy, readonly) NSString *commitSHA;

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

// The path of the file being commented on.
@property (nonatomic, copy, readonly) NSString *path;

// The body of the commit comment.
@property (nonatomic, copy, readonly) NSString *body;

// The date at which the comment was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The date the comment was last updated. This will be equal to
// creationDate if the comment has not been updated.
@property (nonatomic, copy, readonly) NSDate *updatedDate;

// The line index in the commit's diff. This will be nil if the comment refers
// to the entire commit.
@property (nonatomic, copy, readonly) NSNumber *position;

@end
