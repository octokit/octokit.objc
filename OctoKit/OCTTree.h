//
//  OCTTree.h
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A git tree.
@interface OCTTree : OCTObject

// The SHA of the tree.
@property (nonatomic, readonly, copy) NSString *SHA;

// The URL for the tree.
@property (nonatomic, readonly, strong) NSURL *URL;

// The `OCTTreeEntry` objects.
@property (nonatomic, readonly, copy) NSArray *entries;

@end
