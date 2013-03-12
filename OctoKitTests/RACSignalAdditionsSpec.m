//
//  RACSignalAdditionsSpec.m
//  OctoKit
//
//  Created by Alan Rogers on 9/03/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RACSignal+OCTClientAdditions.h"
#import "OCTResponse.h"

SpecBegin(RACSignalAdditions)

it(@"should map OCTResponses to parsedResults", ^{
	NSArray *testValues = @[
		[[OCTResponse alloc] initWithHTTPURLResponse:nil parsedResult:@{ @"key": @"value1" }],
		[[OCTResponse alloc] initWithHTTPURLResponse:nil parsedResult:@{ @"key": @"value2" }],
	];
	
	RACSignal *signal = testValues.rac_sequence.signal;
	
	__block NSUInteger count = 0;
	[signal subscribeNext:^(id x) {
		expect(x).to.beKindOf(OCTResponse.class);
		count++;
	}];
	expect(count).will.equal(2);
	
	count = 0;
	[[signal oct_parsedResults] subscribeNext:^(id x) {
		expect(x).to.beKindOf(NSDictionary.class);
		count++;
	}];
	expect(count).will.equal(2);
});

SpecEnd
