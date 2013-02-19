//
//  OCTClientSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-18.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(OCTClient)

void (^stubResponseForPath)(NSString *, NSString *) = ^(NSString *path, NSString *responseFilename) {
	[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
		if (![request.URL.path isEqual:path]) return nil;
		
		NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:responseFilename.stringByDeletingPathExtension withExtension:responseFilename.pathExtension];
		return [OHHTTPStubsResponse responseWithFileURL:fileURL contentType:@"application/json" responseTime:0];
	}];
};

describe(@"unauthenticated", ^{
	__block OCTClient *client;
	__block BOOL success;
	__block NSError *error;

	beforeEach(^{
		client = [OCTClient clientForUser:[OCTUser userWithName:@"Test User" email:nil]];
		success = NO;
		error = nil;
	});

	it(@"should GET a JSON dictionary", ^{
		stubResponseForPath(@"/rate_limit", @"rate_limit.json");

		RACSignal *request = [client enqueueRequestWithMethod:@"GET" path:@"rate_limit" parameters:nil resultClass:nil];

		__block NSDictionary *result;
		[request subscribeNext:^(id x) {
			result = x;
		} error:^(NSError *e) {
			error = e;
		} completed:^{
			success = YES;
		}];

		expect(success).will.beTruthy();
		expect(error).to.beNil();

		NSDictionary *expected = @{
			@"rate": @{
				@"remaining": @4999,
				@"limit": @5000,
			},
		};

		expect(result).to.equal(expected);
	});
});

SpecEnd
