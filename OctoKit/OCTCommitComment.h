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

@end
