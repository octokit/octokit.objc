//
//  OCTStatus.h
//  OctoKit
//
//  Created by Jackson Harper on 1/10/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// pending, success, error, or failure.

// The state of the status. Can be one of pending,
// success, error, or failure.
//
// OCTStatusStatePending - The state is pending.
// OCTStatusStateSuccess - The state is success.
// OCTStatusStateError - The state is error.
// OCTStatusStateFailure - The state is failure.
typedef enum : NSUInteger {
    OCTStatusStatePending,
    OCTStatusStateSuccess,
	OCTStatusStateError,
	OCTStatusStateFailure,
} OCTStatusState;


@interface OCTStatus : OCTObject

@property (nonatomic, readonly) OCTStatusState state;
@property (nonatomic, copy, readonly) OCTUser *creator;

@property (nonatomic, copy, readonly) NSDate *creationDate;
@property (nonatomic, copy, readonly) NSDate *updatedDate;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *targetURL;
@property (nonatomic, copy, readonly) NSString *message;

@end
