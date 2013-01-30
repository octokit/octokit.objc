//
//  OCTPushEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

// Some commits got pushed.
@interface OCTPushEvent : OCTEvent

// The number of commits included in this push.
//
// Merges count for however many commits were introduced by the other branch.
@property (nonatomic, assign, readonly) NSUInteger commitCount;

// The number of distinct commits included in this push.
@property (nonatomic, assign, readonly) NSUInteger distinctCommitCount;

// The SHA for HEAD prior to this push.
@property (nonatomic, copy, readonly) NSString *previousHeadSHA;

// The SHA for HEAD after this push.
@property (nonatomic, copy, readonly) NSString *currentHeadSHA;

// The branch to which the commits were pushed.
@property (nonatomic, copy, readonly) NSString *branchName;

@end
