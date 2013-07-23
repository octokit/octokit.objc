//
//  OCTSymlinkContent.h
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContent.h"

// A symlink in a git repository.
@interface OCTSymlinkContent : OCTContent

// The path to the symlink target.
@property (nonatomic, copy, readonly) NSString *target;

@end
