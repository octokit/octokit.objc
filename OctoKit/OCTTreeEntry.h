//
//  OCTTreeEntry.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

typedef enum : NSUInteger {
	OCTTreeEntryTypeBlob,
	OCTTreeEntryTypeTree,
	OCTTreeEntryTypeCommit,
} OCTTreeEntryType;

// An entry from a git tree.
@interface OCTTreeEntry : OCTObject

// The SHA of the entry.
@property (nonatomic, readonly, copy) NSString *SHA;

// The repository-relative path.
@property (nonatomic, readonly, copy) NSString *path;

// The URL for the content of the entry.
@property (nonatomic, readonly, strong) NSURL *URL;

// The type of the entry.
@property (nonatomic, readonly, assign) OCTTreeEntryType type;

@end
