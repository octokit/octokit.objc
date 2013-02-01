//
//  ISO8601DateFormatter+OCTFormattingAdditions.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "ISO8601DateFormatter+OCTFormattingAdditions.h"

@implementation ISO8601DateFormatter (OCTFormattingAdditions)

+ (instancetype)oct_standardDateFormatter {
	ISO8601DateFormatter *formatter = [[self alloc] init];
	formatter.format = ISO8601DateFormatCalendar;
	formatter.includeTime = YES;
	return formatter;
}

@end
