//
//  NSValueTransformerAdditionsSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>
@import Nimble;
@import Quick;

QuickSpecBegin(NSValueTransformerAdditions)

it(@"should define a date value transformer", ^{
	NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
	expect(transformer).notTo(beNil());
	expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());

	NSString *str = @"2011-01-26T19:06:43Z";

	NSDate *date = [transformer transformedValue:str];
	expect(date).notTo(beNil());

	expect([transformer transformedValue:date]).to(equal(date));
	expect([transformer reverseTransformedValue:date]).to(equal(str));

	expect([transformer transformedValue:nil]).to(beNil());
	expect([transformer reverseTransformedValue:nil]).to(beNil());
});

QuickSpecEnd
