//
//  OCTIssueComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

// A single comment on an issue.
@interface OCTIssueComment : OCTObject

// The body of the comment.
@property (nonatomic, readonly, copy) NSString *body;

// The author of the comment.
@property (nonatomic, readonly, strong) OCTUser *user;

// The date on which the comment was created.
@property (nonatomic, readonly, strong) NSDate *created;

// The date on which the comment was last updated.
@property (nonatomic, readonly, strong) NSDate *updated;

@end
