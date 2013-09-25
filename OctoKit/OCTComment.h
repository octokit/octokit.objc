//
//  OCTComment.h
//  OctoKit
//
//  Created by Jackson Harper on 9/23/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

// A comment can be added to an issue, pull request, or commit.
@protocol OCTComment <NSObject>

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

// The date at which the comment was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The date the comment was last updated. This will be equal to
// creationDate if the comment has not been updated.
@property (nonatomic, copy, readonly) NSDate *updatedDate;

// The body of the comment.
@property (nonatomic, copy, readonly) NSString *body;

@end
