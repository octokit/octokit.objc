//
//  NSDateFormatter+OCTFormattingAdditions.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

// Extensions for handling date strings in the `YYYY-MM-DDTHH:MM:SSZ` format
// used by the GitHub API.
@interface NSDateFormatter (OCTFormattingAdditions)

// Parses an ISO 8601 date string.
//
// This method is thread-safe.
//
// Returns the parsed date.
+ (NSDate *)oct_dateFromString:(NSString *)str;

// Converts a date into a date string suitable for sending to the GitHub API.
//
// This method is thread-safe.
//
// Returns an ISO 8601 date string.
+ (NSString *)oct_stringFromDate:(NSDate *)date;

@end
