//
//  OCTCommitComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTComment.h"

// A single comment on a commit.
@interface OCTCommitComment : OCTComment

// The SHA of the commit being commented upon.
@property (nonatomic, copy, readonly) NSString *commitSHA;

// The path of the file being commented on.
@property (nonatomic, copy, readonly) NSString *path;

// The line index in the commit's diff. This will be nil if the comment refers
// to the entire commit.
@property (nonatomic, copy, readonly) NSNumber *position;

@end
