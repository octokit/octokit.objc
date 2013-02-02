//
//  NSDateFormatter+OCTFormattingAdditions.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSDateFormatter+OCTFormattingAdditions.h"
#import "ISO8601DateFormatter.h"

@implementation NSDateFormatter (OCTFormattingAdditions)

+ (NSDate *)oct_dateFromString:(NSString *)str {
	NSParameterAssert(str != nil);
	return [[[ISO8601DateFormatter alloc] init] dateFromString:str];
}

+ (NSString *)oct_stringFromDate:(NSDate *)date {
	NSParameterAssert(date != nil);

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	formatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss'Z'";
	formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [formatter stringFromDate:date];
}

@end
