//
//  OCTClientSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-18.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTTestClient.h"
#import "OHHTTPStubs.h"

QuickSpecBegin(OCTClientSpec)

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

void (^stubRedirectResponseURL)(NSURL *, int, NSURL *) = ^(NSURL *URL, int statusCode, NSURL *redirectURL) {
	[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
		if (!([request.URL.scheme isEqual:URL.scheme] && [request.URL.path isEqual:URL.path])) return nil;

		return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:statusCode responseTime:0 headers:@{
			@"Location": redirectURL.absoluteString
		}];
	}];
};

void (^stubResponseURL)(NSURL *, NSString *, NSDictionary *) = ^(NSURL *URL, NSString *responseFilename, NSDictionary *headers) {
	headers = [headers mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"Content-Type": @"application/json",
	}];

	[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
		if (![request.URL isEqual:URL]) return nil;

		NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:responseFilename.stringByDeletingPathExtension withExtension:responseFilename.pathExtension];
		return [OHHTTPStubsResponse responseWithFileURL:fileURL statusCode:200 responseTime:0 headers:headers];
	}];
};

// A random ETag for testing.
NSString *etag = @"644b5b0155e6404a9cc4bd9d8b1ae730";

__block BOOL success;
__block NSError *error;

__block OCTUser *user;

beforeEach(^{
	success = NO;
	error = nil;

	NSDictionary *userDictionary = @{
		@keypath(OCTUser.new, rawLogin): @"octokit-testing-user",
		@keypath(OCTUser.new, login): @"octokit-testing-user",
		@keypath(OCTUser.new, server): OCTServer.dotComServer,
	};

	user = [OCTUser modelWithDictionary:userDictionary error:NULL];
	expect(user).notTo(beNil());
});

describe(@"without a user", ^{
	__block OCTClient *client;

	beforeEach(^{
		client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
		expect(client).notTo(beNil());
		expect(client.user).to(beNil());
		expect(client.authenticated).to(beFalsy());
	});

	it(@"should create a GET request with default parameters", ^{
		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];

		expect(request).notTo(beNil());
		expect(request.URL).to(equal([NSURL URLWithString:@"https://api.github.com/rate_limit?per_page=100"]));
	});

	it(@"should create a POST request with default parameters", ^{
		NSURLRequest *request = [client requestWithMethod:@"POST" path:@"diver/dave" parameters:nil notMatchingEtag:nil];

		expect(request).notTo(beNil());
		expect(request.URL).to(equal([NSURL URLWithString:@"https://api.github.com/diver/dave"]));
	});

	it(@"should create a request using etags", ^{
		NSString *etag = @"\"deadbeef\"";
		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"diver/dan" parameters:nil notMatchingEtag:etag];

		expect(request).notTo(beNil());
		expect(request.URL).to(equal([NSURL URLWithString:@"https://api.github.com/diver/dan?per_page=100"]));
		expect(request.allHTTPHeaderFields[@"If-None-Match"]).to(equal(etag));
	});

	it(@"should GET a JSON dictionary", ^{
		stubResponse(@"/rate_limit", @"rate_limit.json");

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];
		OCTResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(response).notTo(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		NSDictionary *expected = @{
			@"rate": @{
				@"remaining": @4999,
				@"limit": @5000,
			},
		};

		expect(response.parsedResult).to(equal(expected));
	});

	it(@"should conditionally GET a modified JSON dictionary", ^{
		stubResponseWithHeaders(@"/rate_limit", @"rate_limit.json", @{
			@"ETag": etag,
		});

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];
		OCTResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(response).notTo(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		NSDictionary *expected = @{
			@"rate": @{
				@"remaining": @4999,
				@"limit": @5000,
			},
		};

		expect(response.parsedResult).to(equal(expected));
		expect(response.etag).to(equal(etag));
	});

	it(@"should conditionally GET an unmodified endpoint", ^{
		stubResponseWithStatusCode(@"/rate_limit", 304);

		NSURLRequest *request = [client requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:etag];
		RACSignal *result = [client enqueueRequest:request resultClass:nil];

		expect([result asynchronousFirstOrDefault:nil success:&success error:&error]).to(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());
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
			expect(dict).to(beAnInstanceOf(NSDictionary.class));
			expect(dict[@"item"]).notTo(beNil());

			[items addObject:dict[@"item"]];
		}];

		expect([result asynchronouslyWaitUntilCompleted:&error]).to(beTruthy());
		expect(error).to(beNil());

		NSArray *expected = @[ @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
		expect(items).to(equal(expected));
	});

	it(@"should GET a repository", ^{
		stubResponse(@"/repos/octokit/octokit.objc", @"repository.json");

		RACSignal *request = [client fetchRepositoryWithName:@"octokit.objc" owner:@"octokit"];
		OCTRepository *repository = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		expect(repository).to(beAnInstanceOf(OCTRepository.class));
		expect(repository.objectID).to(equal(@"7530454"));
		expect(repository.name).to(equal(@"octokit.objc"));
		expect(repository.ownerLogin).to(equal(@"octokit"));
		expect(repository.repoDescription).to(equal(@"GitHub API client for Objective-C"));
		expect(repository.defaultBranch).to(equal(@"master"));
		expect(repository.isPrivate).to(equal(@NO));
		expect(repository.isFork).to(equal(@NO));
		expect(repository.datePushed).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-07-08T22:08:31Z"]));
		expect(repository.SSHURL).to(equal(@"git@github.com:octokit/octokit.objc.git"));
		expect(repository.HTTPSURL).to(equal([NSURL URLWithString:@"https://github.com/octokit/octokit.objc.git"]));
		expect(repository.gitURL).to(equal([NSURL URLWithString:@"git://github.com/octokit/octokit.objc.git"]));
		expect(repository.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octokit/octokit.objc"]));
	});

	it(@"should return nothing if repository is unmodified", ^{
		stubResponseWithStatusCode(@"/repos/octokit/octokit.objc", 304);

		RACSignal *request = [client fetchRepositoryWithName:@"octokit.objc" owner:@"octokit"];
		expect([request asynchronousFirstOrDefault:nil success:&success error:&error]).to(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());
	});

	it(@"should not GET a non existing repository", ^{
		stubResponse(@"/repos/octokit/octokit.objc", @"repository.json");

		RACSignal *request = [client fetchRepositoryWithName:@"repo-does-not-exist" owner:@"octokit"];
		expect([request asynchronousFirstOrDefault:nil success:&success error:&error]).to(beNil());
		expect(success).to(beFalsy());
		expect(error).notTo(beNil());
	});

	it(@"should not treat all 404s like old server versions", ^{
		stubResponseWithStatusCode(@"/repos/octokit/octokit.objc", 404);

		RACSignal *request = [client fetchRepositoryWithName:@"octokit.objc" owner:@"octokit"];
		NSError *error;
		BOOL success = [request asynchronouslyWaitUntilCompleted:&error];
		expect(success).to(beFalsy());
		expect(error).notTo(beNil());
		expect(error.domain).to(equal(OCTClientErrorDomain));
		expect(error.code).to(equal(OCTClientErrorConnectionFailed));
	});
});

describe(@"authenticated", ^{
	__block OCTClient *client;

	beforeEach(^{
		client = [OCTClient authenticatedClientWithUser:user token:@""];
		expect(client).notTo(beNil());
		expect(client.user).to(equal(user));
		expect(client.authenticated).to(beTruthy());
	});

	it(@"should fetch notifications", ^{
		stubResponse(@"/notifications", @"notifications.json");

		RACSignal *request = [client fetchNotificationsNotMatchingEtag:nil includeReadNotifications:NO updatedSince:nil];
		OCTResponse *response = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		OCTNotification *notification = response.parsedResult;
		expect(notification).to(beAnInstanceOf(OCTNotification.class));
		expect(notification.objectID).to(equal(@"1"));
		expect(notification.title).to(equal(@"Greetings"));
		expect(notification.threadURL).to(equal([NSURL URLWithString:@"https://api.github.com/notifications/threads/1"]));
		expect(notification.subjectURL).to(equal([NSURL URLWithString:@"https://api.github.com/repos/pengwynn/octokit/issues/123"]));
		expect(notification.latestCommentURL).to(equal([NSURL URLWithString:@"https://api.github.com/repos/pengwynn/octokit/issues/comments/123"]));
		expect(notification.type).to(equal(OCTNotificationTypeIssue));
		expect(notification.lastUpdatedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2012-09-25T07:54:41-07:00"]));

		expect(notification.repository).notTo(beNil());
		expect(notification.repository.name).to(equal(@"Hello-World"));
	});

	it(@"should return nothing if notifications are unmodified", ^{
		stubResponseWithStatusCode(@"/notifications", 304);

		RACSignal *request = [client fetchNotificationsNotMatchingEtag:etag includeReadNotifications:NO updatedSince:nil];
		expect([request asynchronousFirstOrDefault:nil success:&success error:&error]).to(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());
	});

	it(@"should fetch user starred repositories", ^{
		stubResponse(@"/user/starred", @"user_starred.json");

		RACSignal *request = [client fetchUserStarredRepositories];
		OCTRepository *repository = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		expect(repository).to(beAnInstanceOf(OCTRepository.class));
		expect(repository.objectID).to(equal(@"3654804"));
		expect(repository.name).to(equal(@"ThisIsATest"));
		expect(repository.ownerLogin).to(equal(@"octocat"));
		expect(repository.repoDescription).to(beNil());
		expect(repository.defaultBranch).to(equal(@"master"));
		expect(repository.isPrivate).to(equal(@NO));
		expect(repository.datePushed).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-03-26T08:31:42Z"]));
		expect(repository.SSHURL).to(equal(@"git@github.com:octocat/ThisIsATest.git"));
		expect(repository.HTTPSURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/ThisIsATest.git"]));
		expect(repository.gitURL).to(equal([NSURL URLWithString:@"git://github.com/octocat/ThisIsATest.git"]));
		expect(repository.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/ThisIsATest"]));
	});

	it(@"should return nothing if user starred repositories are unmodified", ^{
		stubResponseWithStatusCode(@"/user/starred", 304);

		RACSignal *request = [client fetchUserStarredRepositories];
		expect([request asynchronousFirstOrDefault:nil success:&success error:&error]).to(beNil());
		expect(success).to(beTruthy());
		expect(error).to(beNil());
	});
});

describe(@"unauthenticated", ^{
	__block OCTClient *client;

	beforeEach(^{
		client = [OCTClient unauthenticatedClientWithUser:user];
		expect(client).notTo(beNil());
		expect(client.user).to(equal(user));
		expect(client.authenticated).to(beFalsy());
	});

	it(@"should fetch user starred repositories", ^{
		stubResponse([NSString stringWithFormat:@"/users/%@/starred", user.login], @"user_starred.json");

		RACSignal *request = [client fetchUserStarredRepositories];
		OCTRepository *repository = [request asynchronousFirstOrDefault:nil success:&success error:&error];
		expect(success).to(beTruthy());
		expect(error).to(beNil());

		expect(repository).to(beAnInstanceOf(OCTRepository.class));
		expect(repository.objectID).to(equal(@"3654804"));
		expect(repository.name).to(equal(@"ThisIsATest"));
		expect(repository.ownerLogin).to(equal(@"octocat"));
		expect(repository.repoDescription).to(beNil());
		expect(repository.defaultBranch).to(equal(@"master"));
		expect(repository.isPrivate).to(equal(@NO));
		expect(repository.datePushed).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-03-26T08:31:42Z"]));
		expect(repository.SSHURL).to(equal(@"git@github.com:octocat/ThisIsATest.git"));
		expect(repository.HTTPSURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/ThisIsATest.git"]));
		expect(repository.gitURL).to(equal([NSURL URLWithString:@"git://github.com/octocat/ThisIsATest.git"]));
		expect(repository.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/ThisIsATest"]));
	});
});

describe(@"sign in", ^{
	NSURL *dotComLoginURL = [NSURL URLWithString:@"https://github.com/login/oauth/authorize"];

	NSString *clientID = @"deadbeef";
	NSString *clientSecret = @"itsasekret";

	beforeEach(^{
		[OCTClient setClientID:clientID clientSecret:clientSecret];
	});

	it(@"should send the appropriate error when requesting authorization with 2FA on", ^{
		[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
			if (![request.URL.path isEqual:[NSString stringWithFormat:@"/authorizations/clients/%@", clientID]] || ![request.HTTPMethod isEqual:@"PUT"]) return nil;

			NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"authorizations" withExtension:@"json"];
			NSDictionary *headers = @{ @"X-GitHub-OTP": @"required; sms" };
			return [OHHTTPStubsResponse responseWithFileURL:fileURL statusCode:401 responseTime:0 headers:headers];
		}];

		RACSignal *request = [OCTClient signInAsUser:user password:@"" oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository];
		NSError *error;
		BOOL success = [request asynchronouslyWaitUntilCompleted:&error];
		expect(success).to(beFalsy());
		expect(error.domain).to(equal(OCTClientErrorDomain));
		expect(error.code).to(equal(OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired));
		expect([error.userInfo[OCTClientErrorOneTimePasswordMediumKey] integerValue]).to(equal(OCTClientOneTimePasswordMediumSMS));
	});

	it(@"should request authorization", ^{
		stubResponse([NSString stringWithFormat:@"/authorizations/clients/%@", clientID], @"authorizations.json");

		RACSignal *request = [OCTClient signInAsUser:user password:@"" oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository];
		OCTClient *client = [request asynchronousFirstOrDefault:nil success:NULL error:NULL];
		expect(client).notTo(beNil());
		expect(client.user).to(equal(user));
		expect(client.token).to(equal(@"abc123"));
		expect(client.authenticated).to(beTruthy());
	});

	it(@"requests authorization through redirects", ^{
		NSURL *baseURL = [NSURL URLWithString:@"http://enterprise.github.com"];
		NSString *path = [NSString stringWithFormat:@"api/v3/authorizations/clients/%@", clientID];

		NSURL *HTTPURL = [baseURL URLByAppendingPathComponent:path];
		NSURL *HTTPSURL = [[NSURL alloc] initWithScheme:@"https" host:HTTPURL.host path:HTTPURL.path];

		stubResponseURL(HTTPSURL, @"authorizations.json", @{});
		stubRedirectResponseURL(HTTPURL, 301, HTTPSURL);

		OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:baseURL];
		OCTUser *enterpriseUser = [OCTUser userWithRawLogin:user.rawLogin server:enterpriseServer];

		RACSignal *request = [OCTClient signInAsUser:enterpriseUser password:@"" oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository];
		OCTClient *client = [request asynchronousFirstOrDefault:nil success:NULL error:NULL];
		expect(client).notTo(beNil());
		expect(client.authenticated).to(beTruthy());
	});

	it(@"should detect old server versions", ^{
		stubResponseWithStatusCode([NSString stringWithFormat:@"/authorizations/clients/%@", clientID], 404);

		RACSignal *request = [OCTClient signInAsUser:user password:@"" oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository];
		NSError *error;
		BOOL success = [request asynchronouslyWaitUntilCompleted:&error];
		expect(success).to(beFalsy());
		expect(error.domain).to(equal(OCTClientErrorDomain));
		expect(error.code).to(equal(OCTClientErrorUnsupportedServer));
	});

	describe(@"+authorizeWithServerUsingWebBrowser:scopes:", ^{
		__block NSURL *openedURL;
		__block RACDisposable *openedURLDisposable;

		beforeEach(^{
			OCTTestClient.shouldSucceedOpeningURL = YES;

			openedURLDisposable = [OCTTestClient.openedURLs subscribeNext:^(NSURL *URL) {
				openedURL = URL;
			}];
		});

		afterEach(^{
			[openedURLDisposable dispose];
		});

		it(@"should open the login URL", ^{
			[[[OCTTestClient authorizeWithServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository] publish] connect];

			expect(openedURL).toEventuallyNot(beNil());
			expect(openedURL.scheme).to(equal(dotComLoginURL.scheme));
			expect(openedURL.host).to(equal(dotComLoginURL.host));
			expect(openedURL.path).to(equal(dotComLoginURL.path));
		});

		it(@"should only complete after a matching URL is passed to +completeSignInWithCallbackURL:", ^{
			__block NSString *code = nil;
			__block BOOL completed = NO;
			[[OCTTestClient authorizeWithServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository] subscribeNext:^(id x) {
				code = x;
			} completed:^{
				completed = YES;
			}];

			expect(openedURL).toEventuallyNot(beNil());

			NSDictionary *queryArguments = openedURL.oct_queryArguments;
			expect(queryArguments[@"client_id"]).to(equal(clientID));
			expect(queryArguments[@"scope"]).notTo(beNil());

			NSString *state = queryArguments[@"state"];
			expect(state).notTo(beNil());

			NSURL *differentURL = [NSURL URLWithString:@"?state=foobar&code=12345" relativeToURL:dotComLoginURL];
			[OCTTestClient completeSignInWithCallbackURL:differentURL];

			expect(code).to(beNil());
			expect(completed).to(beFalsy());

			NSURL *matchingURL = [NSURL URLWithString:[NSString stringWithFormat:@"?state=%@&code=12345", state] relativeToURL:dotComLoginURL];
			[OCTTestClient completeSignInWithCallbackURL:matchingURL];

			expect(code).to(equal(@"12345"));
			expect(completed).to(beTruthy());
		});

		it(@"should error when the browser cannot be opened", ^{
			OCTTestClient.shouldSucceedOpeningURL = NO;

			NSError *error = nil;
			BOOL success = [[OCTTestClient authorizeWithServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository] waitUntilCompleted:&error];
			expect(success).to(beFalsy());
			expect(error).notTo(beNil());

			expect(error.domain).to(equal(OCTClientErrorDomain));
			expect(error.code).to(equal(OCTClientErrorOpeningBrowserFailed));
		});
	});

	describe(@"+signInToServerUsingWebBrowser:scopes:", ^{
		NSString *token = @"e72e16c7e42f292c6912e7710c838347ae178b4a";

		RACSignal * (^signInAndCallBack)(void) = ^{
			__block NSURL *openedURL;
			[[OCTTestClient.openedURLs take:1] subscribeNext:^(NSURL *URL) {
				openedURL = URL;
			}];

			RACSignal *signal = [[OCTTestClient signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository] replay];
			expect(openedURL).toEventuallyNot(beNil());

			NSString *state = openedURL.oct_queryArguments[@"state"];
			NSURL *matchingURL = [NSURL URLWithString:[NSString stringWithFormat:@"?state=%@&code=12345", state] relativeToURL:dotComLoginURL];
			[OCTTestClient completeSignInWithCallbackURL:matchingURL];

			return signal;
		};

		beforeEach(^{
			OCTTestClient.shouldSucceedOpeningURL = YES;

			stubResponse(@"/user", @"user.json");

			// Stub the access_token response (which is from a different host
			// than the API).
			[OHHTTPStubs addRequestHandler:^ id (NSURLRequest *request, BOOL onlyCheck) {
				if (![request.HTTPMethod isEqual:@"POST"]) return nil;
				if (![request.URL.host isEqual:@"github.com"]) return nil;
				if (![request.URL.path isEqual:@"/login/oauth/access_token"]) return nil;

				NSDictionary *params = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL];
				expect(params).notTo(beNil());
				expect(params[@"client_id"]).to(equal(clientID));
				expect(params[@"client_secret"]).to(equal(clientSecret));
				expect(params[@"code"]).to(equal(@"12345"));

				NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"access_token" withExtension:@"json"];
				return [OHHTTPStubsResponse responseWithFileURL:fileURL statusCode:200 responseTime:0 headers:@{
					@"Content-Type": @"application/json"
				}];
			}];
		});

		it(@"should create an authenticated OCTClient with the received access token", ^{
			BOOL success = NO;
			NSError *error = nil;
			OCTClient *client = [signInAndCallBack() asynchronousFirstOrDefault:nil success:&success error:&error];
			expect(success).to(beTruthy());
			expect(error).to(beNil());
			expect(client).notTo(beNil());

			expect(client.user).notTo(beNil());
			expect(client.user.login).to(equal(user.login));
			expect(client.token).to(equal(token));
			expect(client.authenticated).to(beTruthy());
		});
	});
});

describe(@"+fetchMetadataForServer:", ^{
	it(@"should successfully fetch metadata", ^{
		stubResponse(@"/meta", @"meta.json");

		RACSignal *request = [OCTClient fetchMetadataForServer:OCTServer.dotComServer];
		OCTServerMetadata *meta = [request asynchronousFirstOrDefault:nil success:NULL error:NULL];
		expect(meta).notTo(beNil());
		expect(meta.supportsPasswordAuthentication).to(beTruthy());
	});

	it(@"should fail if /meta doesn't exist", ^{
		stubResponseWithStatusCode(@"/meta", 404);

		RACSignal *request = [OCTClient fetchMetadataForServer:OCTServer.dotComServer];
		NSError *error;
		BOOL success = [request asynchronouslyWaitUntilCompleted:&error];
		expect(success).to(beFalsy());
		expect(error.domain).to(equal(OCTClientErrorDomain));
		expect(error.code).to(equal(OCTClientErrorUnsupportedServer));
	});

	it(@"should successfully fetch metadata through redirects", ^{
		NSURL *baseURL = [NSURL URLWithString:@"http://enterprise.github.com"];
		NSURL *HTTPURL = [baseURL URLByAppendingPathComponent:@"api/v3/meta"];
		NSURL *HTTPSURL = [NSURL URLWithString:@"https://enterprise.github.com/api/v3/meta"];
		stubResponseURL(HTTPSURL, @"meta.json", @{});
		stubRedirectResponseURL(HTTPURL, 301, HTTPSURL);

		OCTServer *server = [OCTServer serverWithBaseURL:baseURL];

		RACSignal *request = [OCTClient fetchMetadataForServer:server];
		NSError *error;
		OCTServerMetadata *meta = [request asynchronousFirstOrDefault:nil success:NULL error:&error];
		expect(error).to(beNil());
		expect(meta).notTo(beNil());
	});
});

describe(@"+HTTPSEnterpriseServerWithServer", ^{
	it(@"should convert a http URL to a HTTPS URL", ^{
		OCTServer *httpServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"http://github.enterprise"]];
		expect(httpServer.baseURL.scheme).to(equal(@"http"));

		OCTServer *httpsServer = [OCTClient HTTPSEnterpriseServerWithServer:httpServer];
		expect(httpsServer.baseURL.scheme).to(equal(@"https"));
		expect(httpsServer.baseURL.host).to(equal(httpServer.baseURL.host));
		expect(httpsServer.baseURL.path).to(equal(@"/"));
	});
});

QuickSpecEnd
