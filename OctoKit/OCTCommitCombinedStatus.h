//
//  OCTCommitCombinedStatus.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/7/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTRepository;

// A combined status for a commit.
@interface OCTCommitCombinedStatus : OCTObject

// The combined state for the commit this combined status belongs to.
@property (nonatomic, copy, readonly) NSString *state;

// The SHA of commit this combined status belongs to.
@property (nonatomic, copy, readonly) NSString *SHA;

// The number of statuses that make up this combined status.
@property (nonatomic, assign, readonly) NSUInteger countOfStatuses;

// The statuses that make up this combined status.
@property (nonatomic, copy, readonly) NSArray *statuses;

// The repository to which the associated commit belongs.
@property (nonatomic, strong, readonly) OCTRepository *repository;

// The URL for the commit this combined status belongs to.
@property (nonatomic, copy, readonly) NSURL *commitURL;

@end
