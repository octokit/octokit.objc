//
//  OCTIssueComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A single comment on an issue.
@interface OCTIssueComment : OCTObject

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

@end
