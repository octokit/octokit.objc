//
//  NSDateFormatter+OCTFormattingAdditions.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSDateFormatter+OCTFormattingAdditions.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation NSDateFormatter (OCTFormattingAdditions)

+ (NSDate *)oct_dateFromString:(NSString *)str {
	NSParameterAssert(str != nil);

	// ISO8601DateFormatter isn't thread-safe, because all instances share some
	// unsynchronized global state, so we want to always access it from the same
	// GCD queue and avoid any race conditions.
	static ISO8601DateFormatter *dateParsingFormatter;
	static dispatch_queue_t dateParsingQueue;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		dateParsingFormatter = [[ISO8601DateFormatter alloc] init];
		dateParsingQueue = dispatch_queue_create("com.github.OctoKit.NSDateFormatter", DISPATCH_QUEUE_SERIAL);
	});

	__block NSDate *date;
	dispatch_sync(dateParsingQueue, ^{
		date = [dateParsingFormatter dateFromString:str];
	});

	return date;
}

+ (NSString *)oct_stringFromDate:(NSDate *)date {
	NSParameterAssert(date != nil);

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [formatter stringFromDate:date];
}

@end
