//
//  OCTClient+Watching.h
//  OctoKit
//
//  Created by Rui Peres on 15/03/2015.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTRepository;

@interface OCTClient (Watching)

/// Stops watching the repository.
///
/// repository - The repository in which to stop watching. This must not be nil.
//
/// Returns a signal which will send complete, or error.
- (RACSignal *)stopWatchingRepository:(OCTRepository *)repository;

@end
