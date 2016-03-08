//
//  OCTGenericHook.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTHook.h"

// A generic representation of a Github hook, used when we encounter hooks that
// we offer no special case handling for. This class provides bare metal access
// to config details of any Github hook.
@interface OCTGenericHook : OCTHook

@property (nonatomic, copy, readonly) NSDictionary *config;

@end
