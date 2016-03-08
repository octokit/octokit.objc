//
//  NSValueTransformer+OCTPredefinedTransformerAdditions.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

// The name for a value transformer that converts GitHub API date strings into
// dates and back.
//
// For backwards compatibility reasons, the forward transformation accepts an
// NSString (which will be parsed) _or_ an NSDate (which will be passed through
// unmodified).
extern NSString * const OCTDateValueTransformerName;

// The name for a value transformer that converts a Github string representation
// of a boolean ("0" or "1") into a NSNumber (with an underlying BOOL) and back.
// Mantle's automatic unboxing ensures this can safely be mapped to native BOOL
// properties.
extern NSString * const OCTBooleanStringValueTransformerName;

@interface NSValueTransformer (OCTPredefinedTransformerAdditions)
@end
