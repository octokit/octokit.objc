//
//  OCTPlan.h
//  OctoKit
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

// Represents the billing plan of a GitHub account.
@interface OCTPlan : OCTObject

// The name of this plan.
@property (nonatomic, copy, readonly) NSString *name;

// The number of collaborators allowed by this plan.
@property (nonatomic, assign, readonly) NSUInteger collaborators;

// The number of kilobytes of disk space allowed by this plan.
@property (nonatomic, assign, readonly) NSUInteger space;

// The number of private repositories allowed by this plan.
@property (nonatomic, assign, readonly) NSUInteger privateRepos;

@end
