//
//  OCTContent.h
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A class cluster for content in a repository, hereforth just “item”. Such as
// files, directories, symlinks and submodules.
@interface OCTContent : OCTObject

// The size of the content, in bytes.
@property (nonatomic, assign, readonly) NSUInteger size;

// The name of the item.
@property (nonatomic, copy, readonly) NSString *name;

// The relative path from the repository root to the item.
@property (nonatomic, copy, readonly) NSString *path;

// The sha reference of the item.
@property (nonatomic, copy, readonly) NSString *SHA;

@end
