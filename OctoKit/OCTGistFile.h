//
//  OCTGistFile.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-07-31.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A single file within a gist.
@interface OCTGistFile : OCTObject

// The path to this file within the gist.
@property (nonatomic, copy, readonly) NSString *filename;

// A direct URL to the raw file contents.
@property (nonatomic, copy, readonly) NSURL *rawURL;

// The size of the file, in bytes.
@property (nonatomic, assign, readonly) NSUInteger size;

@end

// Changes to a single file, or a new file, within a gist.
@interface OCTGistFileEdit : MTLModel <MTLJSONSerializing>

// If not nil, the new filename to set for the file.
@property (atomic, copy) NSString *filename;

// If not nil, the new content to set for the file.
@property (atomic, copy) NSString *content;

@end
