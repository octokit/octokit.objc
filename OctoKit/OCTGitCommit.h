//
//  OCTGitCommit.h
//  OctoKit
//
//  Created by Piet Brauer on 09.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// A git commit.
@interface OCTGitCommit : OCTObject

// The commit URL for this commit.
@property (nonatomic, copy, readonly) NSURL *commitURL;

// The commit message for this commit.
@property (nonatomic, copy, readonly) NSString *message;

// The SHA for this commit.
@property (nonatomic, copy, readonly) NSString *SHA;

// The committer of this commit.
@property (nonatomic, copy, readonly) OCTUser *committer;

// The author of this commit.
@property (nonatomic, copy, readonly) OCTUser *author;

// The date the author signed the commit.
@property (nonatomic, copy, readonly) NSDate *commitDate;

// The number of changes made in the commit.
// This property is only set when fetching a full commit.
@property (nonatomic, readonly) NSUInteger countOfChanges;

// The number of additions made in the commit.
// This property is only set when fetching a full commit.
@property (nonatomic, readonly) NSUInteger countOfAdditions;

// The number of deletions made in the commit.
// This property is only set when fetching a full commit.
@property (nonatomic, readonly) NSUInteger countOfDeletions;

// The OCTGitCommitFile objects changed in the commit.
// This property is only set when fetching a full commit.
@property (nonatomic, copy, readonly) NSArray *files;

// The authors git user.name property. This is only useful if the
// author does not have a GitHub login. Otherwise, author should 
// be used.
@property (nonatomic, copy, readonly) NSString *authorName;

// The committer's git user.name property. This is only useful if the
// committer does not have a GitHub login. Otherwise, committer should
// be used.
@property (nonatomic, copy, readonly) NSString *committerName;

@end
