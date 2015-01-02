//
//  OCTForkEvent.h
//  OctoKit
//
//  Created by Tyler Stromberg on 12/25/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTEvent.h"

// A user forked a repository.
@interface OCTForkEvent : OCTEvent

// The name of the repository created by forking (e.g., `user/Mac`).
@property (nonatomic, copy, readonly) NSString *forkedRepositoryName;

@end
