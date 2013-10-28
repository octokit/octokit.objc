//
//  NSURL+OCTQueryAdditions.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (OCTQueryAdditions)

// Parses the URL's query string into a set of key-value pairs.
//
// Returns a (possibly empty) dictionary of the URL's query arguments. Keys
// without a value will be associated with `NSNull` in the dictionary. If there
// are multiple keys with the same name, it's unspecified which one's value will
// be used.
- (NSDictionary *)oct_queryArguments;

@end
