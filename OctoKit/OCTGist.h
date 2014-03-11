//
//  OCTGist.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-07-31.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A gist.
@interface OCTGist : OCTObject

// The OCTGistFiles in the gist, keyed by filename.
@property (nonatomic, copy, readonly) NSDictionary *files;

// The date at which the gist was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The webpage URL for this gist.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

@end

// Changes to a gist, or a new gist.
@interface OCTGistEdit : MTLModel <MTLJSONSerializing>

// If not nil, the new description to set for the gist.
@property (atomic, copy) NSString *description;

// Files to modify, represented as OCTGistFileEdits keyed by filename.
@property (atomic, copy) NSDictionary *filesToModify;

// Files to add, represented as OCTGistFileEdits.
//
// Each edit must have a `filename` and `content`.
@property (atomic, copy) NSArray *filesToAdd;

// The names of files to delete.
@property (atomic, copy) NSArray *filenamesToDelete;

// Whether this gist should be public.
@property (atomic, getter = isPublicGist, assign) BOOL publicGist;

@end
