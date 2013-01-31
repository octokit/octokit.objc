//
//  NSArray+OCTFlatteningAdditions.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-01-09.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (OCTFlatteningAdditions)

// Recursively replaces all arrays with their contents.
//
// Returns a flat array (one that does not contain any NSArrays itself).
- (NSArray *)oct_flattenedArray;

@end
