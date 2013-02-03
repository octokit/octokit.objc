//
//  NSDateFormatterAdditionsSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSDateFormatter+OCTFormattingAdditions.h"

SpecBegin(NSDateFormatterAdditions)

it(@"should parse an ISO 8601 string into a date and back", ^{
	NSString *str = @"2011-01-26T19:06:43Z";

	NSDate *date = [NSDateFormatter oct_dateFromString:str];
	expect(date).notTo.beNil();
	expect([NSDateFormatter oct_stringFromDate:date]).to.equal(str);
});

it(@"shouldn't use ISO week-numbering year", ^{
	NSString *str = @"2012-01-01T00:00:00Z";

	NSDate *date = [NSDateFormatter oct_dateFromString:str];
	expect(date).notTo.beNil();
	expect([NSDateFormatter oct_stringFromDate:date]).to.equal(str);
});

SpecEnd
