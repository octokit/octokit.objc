//
//  OCTBranch.h
//  OctoKit
//
//  Created by Piet Brauer on 08.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// A GithHub repository branch.
@interface OCTBranch : OCTObject

// The name of the branch.
@property (nonatomic, copy, readonly) NSString *name;

// The SHA of the last commit on this branch.
@property (nonatomic, copy, readonly) NSString *lastCommitSHA;

// The API URL to the last commit on this branch.
@property (nonatomic, copy, readonly) NSURL *lastCommitURL;

@end
