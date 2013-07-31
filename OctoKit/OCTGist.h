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
