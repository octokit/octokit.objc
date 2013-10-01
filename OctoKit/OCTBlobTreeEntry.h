//
//  OCTBlobTreeEntry.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/30/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContentTreeEntry.h"

// A blob tree entry.
@interface OCTBlobTreeEntry : OCTContentTreeEntry

// The size of the blob in bytes.
@property (nonatomic, readonly, assign) NSUInteger size;

@end
