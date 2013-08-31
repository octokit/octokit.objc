//
//  OCTIssueComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTComment.h"

// A single comment on an issue.
@interface OCTIssueComment : OCTComment

// The comment's issue URL.
@property (nonatomic, copy, readonly) NSURL *issueURL;

@end
