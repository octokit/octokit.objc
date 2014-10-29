//
//  NSDateFormatterAdditionsSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-01.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

QuickSpecBegin(NSDateFormatterAdditions)

__block NSCalendar *gregorian;

beforeEach(^{
	gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	gregorian.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
});

it(@"should parse an ISO 8601 string into a date and back", ^{
	NSString *str = @"2011-01-26T19:06:43Z";

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps.day = 26;
	comps.month = 1;
	comps.year = 2011;
	comps.hour = 19;
	comps.minute = 6;
	comps.second = 43;

	NSDate *date = [NSDateFormatter oct_dateFromString:str];
	expect(date).to(equal([gregorian dateFromComponents:comps]));

	expect([NSDateFormatter oct_stringFromDate:date]).to(equal(str));
});

it(@"shouldn't use ISO week-numbering year", ^{
	NSString *str = @"2012-01-01T00:00:00Z";

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps.day = 1;
	comps.month = 1;
	comps.year = 2012;
	comps.hour = 0;
	comps.minute = 0;
	comps.second = 0;

	NSDate *date = [NSDateFormatter oct_dateFromString:str];
	expect(date).to(equal([gregorian dateFromComponents:comps]));

	expect([NSDateFormatter oct_stringFromDate:date]).to(equal(str));
});

QuickSpecEnd
