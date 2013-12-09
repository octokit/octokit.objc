//
//  OCTCommit.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A git commit.
@interface OCTCommit : OCTObject

// The SHA for this commit.
@property (nonatomic, copy, readonly) NSString *SHA;

// The API URL to the tree that this commit points to.
@property (nonatomic, copy, readonly) NSURL *treeURL;

// The SHA of the tree that this commit points to.
@property (nonatomic, copy, readonly) NSString *treeSHA;

@end
