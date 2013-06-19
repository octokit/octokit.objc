//
//  OCTCreateEvent.h
//  OctoKit
//
//  Created by Josh Vera on 6/19/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTRefEvent.h"

@interface OCTCreateEvent : OCTRefEvent

// The name of the repository's master branch.
@property (nonatomic, strong, readonly) NSString *masterBranch;

// The repository's current description.
@property (nonatomic, strong, readonly) NSString *repositoryDescription;

@end
