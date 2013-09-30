//
//  OCTContentTreeEntry.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/30/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// A content entry which has a URL.
@interface OCTContentTreeEntry : OCTTreeEntry

// The URL for the content of the entry.
@property (nonatomic, readonly, strong) NSURL *URL;

@end
