//
//  ISO8601DateFormatter+OCTFormattingAdditions.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "ISO8601DateFormatter.h"

@interface ISO8601DateFormatter (OCTFormattingAdditions)

// Returns a new date formatter initialized to parse and generate date strings
// in the standard GitHub format.
+ (instancetype)oct_standardDateFormatter;

@end
