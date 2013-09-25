//
//  OCTReviewComment.h
//  OctoKit
//
//  Created by Jackson Harper on 9/23/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTComment.h"

// A review comment is a comment that occurs on a portion of a
// unified diff, such as a commit or a pull request. If the comment
// refers to the entire entity, the path and position properties
// will be nil.
@protocol OCTReviewComment <OCTComment>

// The relative path of the file being commented on. This
// will be nil if the comment refers to the entire entity,
// not a specific path in the diff.
@property (nonatomic, copy, readonly) NSString *path;

// The current HEAD SHA of the code being commented on.
@property (nonatomic, copy, readonly) NSString *commitSHA;

// The line index of the code being commented on. This
// will be nil if the comment refers to the entire review
// entity (commit/pull request).
@property (nonatomic, copy, readonly) NSNumber *position;

@end
