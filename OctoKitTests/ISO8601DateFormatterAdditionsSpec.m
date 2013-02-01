//
//  ISO8601DateFormatterAdditionsSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "ISO8601DateFormatter+OCTFormattingAdditions.h"

SpecBegin(ISO8601DateFormatterAdditions)

__block ISO8601DateFormatter *formatter;

beforeEach(^{
	formatter = [ISO8601DateFormatter oct_standardDateFormatter];
	expect(formatter).notTo.beNil();
});

it(@"should parse an ISO 8601 string into a date and back", ^{
	NSString *str = @"2011-01-26T19:06:43Z";

	NSDate *date = [formatter dateFromString:str];
	expect(date).notTo.beNil();

	// Can't test string equivalence because -stringFromDate:timeZone: is
	// broken, and the string from this method might be in an offset TZ. We'll
	// test creating _another_ date object instead.
	NSString *reverseStr = [formatter stringFromDate:date];
	expect(reverseStr).notTo.beNil();

	expect([formatter dateFromString:reverseStr]).to.equal(date);
});

SpecEnd
