//
//  OCTComment.h
//  OctoKit
//
//  Created by Josh Vera on 6/26/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

@interface OCTComment : OCTObject

// The body of the comment.
@property (nonatomic, copy, readonly) NSString *body;

// The html body of the comment.
@property (nonatomic, copy, readonly) NSString *HTMLBody;

// The comment's webpage URL.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The comment's API URL.
@property (nonatomic, copy, readonly) NSURL *APIURL;

// The comment's created at date.
@property (nonatomic, copy, readonly) NSDate *createdAtDate;

// The comment's updated at date.
@property (nonatomic, copy, readonly) NSDate *updatedAtDate;

// The login of the user who created this comment.
@property (nonatomic, copy, readonly) NSString *commenterLogin;

@end
