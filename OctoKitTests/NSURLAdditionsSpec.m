//
//  NSURLAdditionsSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-25.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

QuickSpecBegin(NSURLAdditions)

describe(@"-oct_queryArguments", ^{
	it(@"should return an empty dictionary for no query string", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com"];
		expect(URL.oct_queryArguments).to(equal(@{}));
	});

	it(@"should return an empty dictionary for an empty query string", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com?"];
		expect(URL.oct_queryArguments).to(equal(@{}));
	});

	it(@"should return key value pairs", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com?foo=bar&baz=buzz&fuzz"];
		NSDictionary *expected = @{
			@"foo": @"bar",
			@"baz": @"buzz",
			@"fuzz": NSNull.null
		};

		expect(URL.oct_queryArguments).to(equal(expected));
	});

	it(@"should return key value pairs when separated by semicolons", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com?foo=bar;baz=buzz;fuzz"];
		NSDictionary *expected = @{
			@"foo": @"bar",
			@"baz": @"buzz",
			@"fuzz": NSNull.null
		};

		expect(URL.oct_queryArguments).to(equal(expected));
	});

	it(@"should pick one value when the same key is specified multiple times", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com?a=1&a=2&a=3"];
		expect(URL.oct_queryArguments.allKeys).to(equal((@[ @"a" ])));

		NSInteger value = [URL.oct_queryArguments[@"a"] integerValue];
		expect(value).to(beGreaterThanOrEqualTo(1));
		expect(value).to(beLessThanOrEqualTo(3));
	});

	it(@"should replace percent escapes", ^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com?foo%20bar=fuzz%3Dbuzz"];
		NSDictionary *expected = @{
			@"foo bar": @"fuzz=buzz",
		};

		expect(URL.oct_queryArguments).to(equal(expected));
	});
});

QuickSpecEnd
