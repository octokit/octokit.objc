//
//  OCTFileContent.h
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContent.h"

// A file in a git repository.
@interface OCTFileContent : OCTContent

// The encoding of the file content.
@property (nonatomic, copy, readonly) NSString *encoding;

// The raw, encoded, content of the file.
//
// See `encoding` for the encoding used.
@property (nonatomic, copy, readonly) NSString *content;

@end
