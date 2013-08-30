//
//  OCTPullRequestComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTComment.h"

// A single comment on a pull request.
@interface OCTPullRequestComment : OCTComment

// The API URL for the pull request upon which this comment appears.
@property (nonatomic, copy, readonly) NSURL *pullRequestAPIURL;

@end
