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

__block BOOL success;
__block NSError *error;

// A random ETag for testing.
NSString *etag = @"644b5b0155e6404a9cc4bd9d8b1ae730";

beforeEach(^{
	success = NO;
	error = nil;
});

describe(@"without a user", ^{
	__block OCTClient *client;

	beforeEach(^{
		client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
		expect(client).notTo.beNil();
		expect(client.user).to.beNil();
		expect(client.authenticated).to.beFalsy();
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
	
	it(@"should GET a repository", ^{
		stubResponse(@"/repos/octokit/octokit.objc", @"repository.json");
		
		RACSignal *request = [client fetchRepositoryWithName:@"octokit.objc" owner:@"octokit"];
		OCTRepository *repository = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to.beTruthy();
		expect(error).to.beNil();
		
		expect(repository).to.beKindOf(OCTRepository.class);
		expect(repository.objectID).to.equal(@"7530454");
		expect(repository.name).to.equal(@"octokit.objc");
		expect(repository.ownerLogin).to.equal(@"octokit");
		expect(repository.repoDescription).to.equal(@"GitHub API client for Objective-C");
		expect(repository.defaultBranch).to.equal(@"master");
		expect(repository.isPrivate).to.equal(@NO);
		expect(repository.isFork).to.equal(@NO);
		expect(repository.datePushed).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-07-08T22:08:31Z"]);
		expect(repository.SSHURL).to.equal(@"git@github.com:octokit/octokit.objc.git");
		expect(repository.HTTPSURL).to.equal([NSURL URLWithString:@"https://github.com/octokit/octokit.objc.git"]);
		expect(repository.gitURL).to.equal([NSURL URLWithString:@"git://github.com/octokit/octokit.objc.git"]);
		expect(repository.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octokit/octokit.objc"]);
	});
	
	it(@"should not GET a non existing repository", ^{
		stubResponse(@"/repos/octokit/octokit.objc", @"repository.json");
		
		RACSignal *request = [client fetchRepositoryWithName:@"repo-does-not-exist" owner:@"octokit"];
		OCTRepository *repository = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to.beFalsy();
		expect(error).notTo.beNil();
		expect(repository).to.beNil();
	});
});

describe(@"authenticated", ^{
	__block OCTUser *user;
	__block OCTClient *client;

	beforeEach(^{
		user = [OCTUser userWithLogin:@"mac-testing-user" server:OCTServer.dotComServer];
		expect(user).notTo.beNil();

		client = [OCTClient authenticatedClientWithUser:user password:@""];
		expect(client).notTo.beNil();
		expect(client.user).to.equal(user);
		expect(client.authenticated).to.beTruthy();
	});

	it(@"should fetch notifications", ^{
		stubResponse(@"/notifications", @"notifications.json");

		RACSignal *request = [client fetchNotificationsNotMatchingEtag:nil includeReadNotifications:NO updatedSince:nil];
		OCTResponse *response = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to.beTruthy();
		expect(error).to.beNil();

		OCTNotification *notification = response.parsedResult;
		expect(notification).to.beKindOf(OCTNotification.class);
		expect(notification.objectID).to.equal(@"1");
		expect(notification.title).to.equal(@"Greetings");
		expect(notification.threadURL).to.equal([NSURL URLWithString:@"https://api.github.com/notifications/threads/1"]);
		expect(notification.subjectURL).to.equal([NSURL URLWithString:@"https://api.github.com/repos/pengwynn/octokit/issues/123"]);
		expect(notification.latestCommentURL).to.equal([NSURL URLWithString:@"https://api.github.com/repos/pengwynn/octokit/issues/comments/123"]);
		expect(notification.type).to.equal(OCTNotificationTypeIssue);
		expect(notification.lastUpdatedDate).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2012-09-25T07:54:41-07:00"]);

		expect(notification.repository).notTo.beNil();
		expect(notification.repository.name).to.equal(@"Hello-World");
	});

	it(@"should return nothing if notifications are unmodified", ^{
		stubResponseWithStatusCode(@"/notifications", 304);

		RACSignal *request = [client fetchNotificationsNotMatchingEtag:etag includeReadNotifications:NO updatedSince:nil];
		expect([request asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil();
		expect(success).to.beTruthy();
		expect(error).to.beNil();
	});
});

SpecEnd
