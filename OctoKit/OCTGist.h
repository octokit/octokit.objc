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

@end

// Changes to a gist, or a new gist.
@interface OCTGistEdit : MTLModel

// If not nil, the new description to set for the gist.
@property (atomic, copy) NSString *description;

// If not nil, the files to add, modify, or delete.
//
// Represented as a dictionary of OCTGistFileEdits, keyed by filename. To delete
// a file, associate its name with NSNull.
@property (atomic, copy) NSDictionary *fileChanges;

// Whether this gist should be public.
@property (atomic, getter = isPublicGist, assign) BOOL publicGist;

@end
