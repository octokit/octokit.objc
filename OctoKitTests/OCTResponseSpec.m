//
//  OCTResponseSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-03-14.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

NSString *etag = @"\"644b5b0155e6404a9cc4bd9d8b1ae730\"";

QuickSpecBegin(OCTResponseSpec)

__block NSMutableDictionary *headers;
__block OCTResponse * (^responseWithHeaders)(void);

beforeEach(^{
	headers = [@{
		@"ETag": etag,
		@"X-RateLimit-Limit": @"5000",
		@"X-RateLimit-Remaining": @"4900",
	} mutableCopy];

	responseWithHeaders = [^{
		NSHTTPURLResponse *URLResponse = [[NSHTTPURLResponse alloc] initWithURL:OCTServer.dotComServer.APIEndpoint statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:headers];
		expect(URLResponse).notTo.beNil();

		OCTResponse *response = [[OCTResponse alloc] initWithHTTPURLResponse:URLResponse parsedResult:nil];
		expect(response).notTo.beNil();

		return response;
	} copy];
});

it(@"should have an etag", ^{
	expect(responseWithHeaders().etag).to.equal(etag);
});

it(@"should have rate limit info", ^{
	OCTResponse *response = responseWithHeaders();
	expect(response.maximumRequestsPerHour).to.equal(5000);
	expect(response.remainingRequests).to.equal(4900);
});

it(@"should not have a poll interval by default", ^{
	expect(responseWithHeaders().pollInterval).to.beNil();
});

it(@"should have a poll interval when the header is present", ^{
	headers[@"X-Poll-Interval"] = @"2.5";
	expect(responseWithHeaders().pollInterval).to.beCloseTo(@2.5);
});

QuickSpecEnd
