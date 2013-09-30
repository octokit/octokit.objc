//
//  OCTTreeEntry.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// The types of tree entries.
//   OCTTreeEntryTypeBlob   - A blob of data.
//   OCTTreeEntryTypeTree   - A tree of entries.
//   OCTTreeEntryTypeCommit - A commit.
typedef enum : NSUInteger {
	OCTTreeEntryTypeBlob,
	OCTTreeEntryTypeTree,
	OCTTreeEntryTypeCommit,
} OCTTreeEntryType;

// The file mode of the entry.
//   OCTTreeEntryModeFile         - File (blob) mode.
//   OCTTreeEntryModeExecutable   - Executable (blob) mode.
//   OCTTreeEntryModeSubdirectory - Subdirectory (tree) mode.
//   OCTTreeEntryModeSubmodule    - Submodule (commit) mode.
//   OCTTreeEntryModeSymlink      - Blob which specifies the path of a symlink.
typedef enum : NSUInteger {
	OCTTreeEntryModeFile,
	OCTTreeEntryModeExecutable,
	OCTTreeEntryModeSubdirectory,
	OCTTreeEntryModeSubmodule,
	OCTTreeEntryModeSymlink,
} OCTTreeEntryMode;

// A class cluster for git tree entries.
@interface OCTTreeEntry : OCTObject

// The SHA of the entry.
@property (nonatomic, readonly, copy) NSString *SHA;

// The repository-relative path.
@property (nonatomic, readonly, copy) NSString *path;

// The type of the entry.
@property (nonatomic, readonly, assign) OCTTreeEntryType type;

// The mode of the entry.
@property (nonatomic, readonly, assign) OCTTreeEntryMode mode;

@end
