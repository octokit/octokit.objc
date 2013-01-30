//
//  OCTCommitCommentEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

@class OCTCommitComment;

// A user commented on a commit.
@interface OCTCommitCommentEvent : OCTEvent

// The comment that was posted.
@property (nonatomic, strong, readonly) OCTCommitComment *comment;

@end
