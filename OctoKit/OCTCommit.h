//
//  OCTCommit.h
//  OctoKit
//
//  Created by Jackson Harper on 8/8/13.
//  Copyright (c) 2013 SyntaxTree, Inc. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

// A single commit to a repository.
@interface OCTCommit : OCTObject

// The SHA for this commit.
@property (nonatomic, copy, readonly) NSString *SHA;

// The URL for this commit.
@property (nonatomic, copy, readonly) NSURL *URL;

// The html URL for this commit.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The comments URL for this commit.
@property (nonatomic, copy, readonly) NSURL *commentsURL;

// The comments for the commit.
@property (nonatomic, copy, readonly) NSArray *comments;

// The date/time this commit was authored.
@property (nonatomic, copy, readonly) NSDate *authorDate;

// The date/time this commit was commited.
@property (nonatomic, copy, readonly) NSDate *commitDate;

// The author of the commit.
@property (nonatomic, copy, readonly) OCTUser *author;

// The user that commited.
@property (nonatomic, copy, readonly) OCTUser *committer;

@property (nonatomic, copy, readonly) NSString *message;

@end
