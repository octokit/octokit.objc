//
//  OCTMilestone.h
//  OctoKit
//
//  Created by Toby Boudreaux on 6/10/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OTCIssue;

// The state of the milestone.
//
// OCTMilestoneStateOpen		- The milestone is open for commits.
// OCTMilestoneStateClosed		- The milestone is closed to commits.
typedef enum : NSString {
    OCTMilestoneStateOpen	= @"open",
    OCTMilestoneStateClosed	= @"closed",
} OCTMilestoneState;

@interface OCTMilestone : OCTObject

// The webpage URL for this milestone.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this milestone.
@property (nonatomic, copy, readonly) NSString *title;

// The state of this milestone.
@property (nonatomic, copy, readonly) NSString *state;

// The date of the deadline
@property (nonatomic, strong, readonly) NSDate *dueOnDate;

// The date of creation
@property (nonatomic, strong, readonly) NSDate *dateCreated;

// The number associated with the milestone, relative to the repository
@property (nonatomic, readonly) NSNumber number;

@end
