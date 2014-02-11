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

// The date of the commit.
@property (nonatomic, copy, readonly) NSDate *commitDate;

@end
