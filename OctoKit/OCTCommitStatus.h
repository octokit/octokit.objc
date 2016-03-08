//
//  OCTCommitStatus.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/7/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTObject.h"

extern NSString * const OCTCommitStatusStateSuccess;
extern NSString * const OCTCommitStatusStateFailure;
extern NSString * const OCTCommitStatusStateError;
extern NSString * const OCTCommitStatusStatePending;

@class OCTUser;

// A status belonging to a commit.
@interface OCTCommitStatus : OCTObject

// The date at which the status was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The date the status was last updated. This will be equal to
// creationDate if the status has not been updated.
@property (nonatomic, copy, readonly) NSDate *updatedDate;

// The state of this status.
@property (nonatomic, copy, readonly) NSString *state;

// The URL where more information can be found about this status. Typically this
// URL will display the build output for the commit this status belongs to.
@property (nonatomic, copy, readonly) NSURL *targetURL;

// A description for this status. Typically this will be a high-level summary of
// the build output for the commit this status belongs to.
@property (nonatomic, copy, readonly) NSString *statusDescription;

// A context indicating which service (or kind of service) provided the status.
@property (nonatomic, copy, readonly) NSString *context;

// The user whom created this status.
@property (nonatomic, copy, readonly) OCTUser *creator;

@end
