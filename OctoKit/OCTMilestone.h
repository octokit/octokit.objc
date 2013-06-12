//
//  OCTMilestone.h
//  OctoKit
//
//  Created by Toby Boudreaux on 6/10/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OTCIssue;

@interface OCTMilestone : OCTObject

// The webpage URL for this milestone.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this milestone.
@property (nonatomic, copy, readonly) NSString *title;

// The state of this milestone.
@property (nonatomic, copy, readonly) NSString *state;

// The date of the deadline
@property (nonatomic, strong, readonly) NSDate *dueOnDate;

@property (nonatomic, readonly) int number;

@end
