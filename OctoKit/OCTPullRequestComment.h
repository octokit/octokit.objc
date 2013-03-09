//
//  OCTPullRequestComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A single comment on a pull request.
@interface OCTPullRequestComment : OCTObject

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The API URL for the pull request upon which this comment appears.
@property (nonatomic, copy, readonly) NSURL *pullRequestAPIURL;

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

@end
