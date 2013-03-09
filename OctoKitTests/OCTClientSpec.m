//
//  OCTClientSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-18.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(OCTClient)

void (^stubResponseWithHeaders)(NSString *, NSString *, NSDictionary *) = ^(NSString *path, NSString *responseFilename, NSDictionary *headers) {
	headers = [headers mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"Content-Type": @"application/json",
	}];

	[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
		if (![request.URL.path isEqual:path]) return nil;
		
		NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:responseFilename.stringByDeletingPathExtension withExtension:responseFilename.pathExtension];
		return [OHHTTPStubsResponse responseWithFileURL:fileURL statusCode:200 responseTime:0 headers:headers];
	}];
};

void (^stubResponseWithStatusCode)(NSString *, int) = ^(NSString *path, int statusCode) {
	[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
		if (![request.URL.path isEqual:path]) return nil;

		return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:statusCode responseTime:0 headers:nil];
	}];
};

void (^stubResponse)(NSString *, NSString *) = ^(NSString *path, NSString *responseFilename) {
	stubResponseWithHeaders(path, responseFilename, @{});
};

describe(@"without a user", ^{
	__block OCTClient *client;
	__block BOOL success;
	__block NSError *error;

	beforeEach(^{
		client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
		expect(client).notTo.beNil();
		expect(client.user).to.beNil();
		expect(client.authenticated).to.beFalsy();

		success = NO;
		error = nil;
	});
	
	it(@"should create a GET request with default parameters", ^{
		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
		
		expect(request).toNot.beNil();
		expect(request.URL).to.equal([NSURL URLWithString:@"https://api.github.com/rate_limit?per_page=100"]);
	});
	
	it(@"should create a POST request with default parameters", ^{
		NSURLRequest *request = [client requestWithMethod:@"POST" path:@"diver/dave" parameters:nil notMatchingEtag:nil];
		
		expect(request).toNot.beNil();
		expect(request.URL).to.equal([NSURL URLWithString:@"https://api.github.com/diver/dave"]);
	});
	
	it(@"should create a request using etags", ^{
		NSString *etag = @"\"deadbeef\"";
		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"diver/dan" parameters:nil notMatchingEtag:etag];
		
		expect(request).toNot.beNil();
		expect(request.URL).to.equal([NSURL URLWithString:@"https://api.github.com/diver/dan?per_page=100"]);
		expect(request.allHTTPHeaderFields[@"If-None-Match"]).to.equal(etag);
	});

	it(@"should GET a JSON dictionary", ^{
		stubResponse(@"/rate_limit", @"rate_limit.json");

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];
		OCTResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(response).notTo.beNil();
		expect(success).to.beTruthy();
		expect(error).to.beNil();

		NSDictionary *expected = @{
			@"rate": @{
				@"remaining": @4999,
				@"limit": @5000,
			},
		};

		expect(response.parsedResult).to.equal(expected);
	});

	it(@"should conditionally GET a modified JSON dictionary", ^{
		NSString *etag = @"644b5b0155e6404a9cc4bd9d8b1ae730";

		stubResponseWithHeaders(@"/rate_limit", @"rate_limit.json", @{
			@"ETag": etag,
		});

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];
		OCTResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(response).notTo.beNil();
		expect(success).to.beTruthy();
		expect(error).to.beNil();

		NSDictionary *expected = @{
			@"rate": @{
				@"remaining": @4999,
				@"limit": @5000,
			},
		};

		expect(response.parsedResult).to.equal(expected);
		expect(response.etag).to.equal(etag);
	});

	it(@"should conditionally GET an unmodified endpoint", ^{
		NSString *etag = @"644b5b0155e6404a9cc4bd9d8b1ae730";

		stubResponseWithStatusCode(@"/rate_limit", 304);

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:etag];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];

		expect([result asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil();
		expect(success).to.beTruthy();
		expect(error).to.beNil();
	});

	it(@"should GET a paginated endpoint", ^{
		stubResponseWithHeaders(@"/items1", @"page1.json", @{
			@"Link": @"<https://api.github.com/items2>; rel=\"next\", <https://api.github.com/items3>; rel=\"last\"",
		});

		stubResponseWithHeaders(@"/items2", @"page2.json", @{
			@"Link": @"<https://api.github.com/items3>; rel=\"next\", <https://api.github.com/items3>; rel=\"last\"",
		});

		stubResponse(@"/items3", @"page3.json");

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"items1" parameters:nil notMatchingEtag:nil];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];

		__block NSMutableArray *items = [NSMutableArray array];
		[result subscribeNext:^(OCTResponse *response) {
			NSDictionary *dict = response.parsedResult;
			expect(dict).to.beKindOf(NSDictionary.class);
			expect(dict[@"item"]).notTo.beNil();

			[items addObject:dict[@"item"]];
		}];

		expect([result asynchronouslyWaitUntilCompleted:&error]).to.beTruthy();
		expect(error).to.beNil();

		NSArray *expected = @[ @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
		expect(items).to.equal(expected);
	});
});

SpecEnd
