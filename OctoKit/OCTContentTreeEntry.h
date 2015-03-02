//
//  OCTContentTreeEntry.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/30/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTTreeEntry.h"

// A tree entry which has URL-addressable content.
@interface OCTContentTreeEntry : OCTTreeEntry

// The URL for the content of the entry.
@property (nonatomic, readonly, strong) NSURL *URL;

@end
