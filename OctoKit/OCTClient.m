//
//  OCTClient.m
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTClient.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"
#import "OCTAccessToken.h"
#import "OCTAuthorization.h"
#import "OCTContent.h"
#import "OCTEvent.h"
#import "OCTGist.h"
#import "OCTGistFile.h"
#import "OCTNotification.h"
#import "OCTObject+Private.h"
#import "OCTOrganization.h"
#import "OCTPublicKey.h"
#import "OCTRepository.h"
#import "OCTResponse.h"
#import "OCTServer.h"
#import "OCTTeam.h"
#import "OCTTree.h"
#import "OCTUser.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

NSString * const OCTClientErrorDomain = @"OCTClientErrorDomain";
const NSInteger OCTClientErrorAuthenticationFailed = 666;
const NSInteger OCTClientErrorServiceRequestFailed = 667;
const NSInteger OCTClientErrorConnectionFailed = 668;
const NSInteger OCTClientErrorJSONParsingFailed = 669;
const NSInteger OCTClientErrorBadRequest = 670;
const NSInteger OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired = 671;
const NSInteger OCTClientErrorUnsupportedServer = 672;
const NSInteger OCTClientErrorOpeningBrowser = 673;

NSString * const OCTClientErrorRequestURLKey = @"OCTClientErrorRequestURLKey";
NSString * const OCTClientErrorHTTPStatusCodeKey = @"OCTClientErrorHTTPStatusCodeKey";
NSString * const OCTClientErrorOneTimePasswordMediumKey = @"OCTClientErrorOneTimePasswordMediumKey";

static const NSInteger OCTClientNotModifiedStatusCode = 304;
static NSString * const OCTClientOneTimePasswordHeaderField = @"X-GitHub-OTP";

// An environment variable that, when present, will enable logging of all
// responses.
static NSString * const OCTClientResponseLoggingEnvironmentKey = @"LOG_API_RESPONSES";

// An environment variable that, when present, will log the remaining API calls
// allowed before the rate limit is enforced.
static NSString * const OCTClientRateLimitLoggingEnvironmentKey = @"LOG_REMAINING_API_CALLS";

@interface OCTClient ()
@property (nonatomic, strong, readwrite) OCTUser *user;
@property (nonatomic, copy, readwrite) NSString *token;

// Returns any user agent previously given to +setUserAgent:.
+ (NSString *)userAgent;

// Returns any OAuth client ID previously given to +setClientID:clientSecret:.
+ (NSString *)clientID;

// Returns any OAuth client secret previously given to
// +setClientID:clientSecret:.
+ (NSString *)clientSecret;

// A subject to send callback URLs to after they're received by the app.
+ (RACSubject *)callbackURLs;

// An error indicating that a request required a valid user, but no `user`
// property was set.
+ (NSError *)userRequiredError;

// An error indicating that a request required authentication, but the client
// was not created with a token.
+ (NSError *)authenticationRequiredError;

// Enqueues a request to fetch information about the current user by accessing
// a path relative to the user object.
//
// method       - The HTTP method to use.
// relativePath - The path to fetch, relative to the user object. For example,
//                to request `user/orgs` or `users/:user/orgs`, simply pass in
//                `/orgs`. This may not be nil, and must either start with a '/'
//                or be an empty string.
// parameters   - HTTP parameters to encode and send with the request.
// resultClass  - The class that response data should be returned as.
//
// Returns a signal which will send an instance of `resultClass` for each parsed
// JSON object, then complete. If no `user` is set on the receiver, the signal
// will error immediately.
- (RACSignal *)enqueueUserRequestWithMethod:(NSString *)method relativePath:(NSString *)relativePath parameters:(NSDictionary *)parameters resultClass:(Class)resultClass;

// Creates a request.
//
// method - The HTTP method to use in the request (e.g., "GET" or "POST").
// path   - The path to request, relative to the base API endpoint. This path
//          should _not_ begin with a forward slash.
// etag   - An ETag to compare the server data against, previously retrieved
//          from an instance of OCTResponse.
//
// Returns a request which can be modified further before being enqueued.
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag;

// Launches the default web browser to the sign in page for the given server.
//
// Returns a signal that sends a temporary OAuth code when +handleCallbackURL:
// is invoked with a matching callback URL, then completes. If any error occurs
// opening the web browser, it will be sent on the returned signal.
+ (RACSignal *)authorizeWithServerUsingWebBrowser:(OCTServer *)server callbackURL:(NSURL *)callbackURL scopes:(OCTClientAuthorizationScopes)scopes clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

@end

@implementation OCTClient

#pragma mark Properties

- (BOOL)isAuthenticated {
	return self.token != nil;
}

- (void)setToken:(NSString *)token {
	_token = [token copy];

	if (token == nil) {
		[self clearAuthorizationHeader];
	} else {
		[self setAuthorizationHeaderWithToken:token];
	}
}

#pragma mark Class Properties

static NSString *OCTClientUserAgent = nil;
static NSString *OCTClientOAuthClientID = nil;
static NSString *OCTClientOAuthClientSecret = nil;

+ (dispatch_queue_t)globalSettingsQueue {
	static dispatch_queue_t settingsQueue;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		settingsQueue = dispatch_queue_create("com.github.OctoKit.globalSettingsQueue", DISPATCH_QUEUE_CONCURRENT);
	});

	return settingsQueue;
}

+ (void)setUserAgent:(NSString *)userAgent {
	NSParameterAssert(userAgent != nil);

	NSString *copiedAgent = [userAgent copy];

	dispatch_barrier_async(self.globalSettingsQueue, ^{
		OCTClientUserAgent = copiedAgent;
	});
}

+ (NSString *)userAgent {
	__block NSString *value = nil;

	dispatch_sync(self.globalSettingsQueue, ^{
		value = OCTClientUserAgent;
	});

	return value;
}

+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
	NSParameterAssert(clientID != nil);
	NSParameterAssert(clientSecret != nil);

	NSString *copiedID = [clientID copy];
	NSString *copiedSecret = [clientSecret copy];

	dispatch_barrier_async(self.globalSettingsQueue, ^{
		OCTClientOAuthClientID = copiedID;
		OCTClientOAuthClientSecret = copiedSecret;
	});
}

+ (NSString *)clientID {
	__block NSString *value = nil;

	dispatch_sync(self.globalSettingsQueue, ^{
		value = OCTClientOAuthClientID;
	});

	return value;
}

+ (NSString *)clientSecret {
	__block NSString *value = nil;

	dispatch_sync(self.globalSettingsQueue, ^{
		value = OCTClientOAuthClientSecret;
	});

	return value;
}

+ (RACSubject *)callbackURLs {
	static RACSubject *singleton;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		singleton = [[RACSubject subject] setNameWithFormat:@"OCTClient.callbackURLs"];
	});

	return singleton;
}

+ (NSError *)userRequiredError {
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: NSLocalizedString(@"Username Required", @""),
		NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No username was provided for getting user information.", @""),
	};

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorAuthenticationFailed userInfo:userInfo];
}

+ (NSError *)authenticationRequiredError {
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: NSLocalizedString(@"Login Required", @""),
		NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"You must log in to access user information.", @""),
	};

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorAuthenticationFailed userInfo:userInfo];
}

#pragma mark Lifecycle

- (id)initWithBaseURL:(NSURL *)url {
	NSAssert(NO, @"%@ must be initialized using -initWithServer:", self.class);
	return nil;
}

- (id)initWithServer:(OCTServer *)server {
	NSParameterAssert(server != nil);

	self = [super initWithBaseURL:server.APIEndpoint];
	if (self == nil) return nil;

	NSString *userAgent = self.class.userAgent;
	NSAssert(userAgent != nil, @"+setUserAgent: must be invoked before initializing OCTClient");

	self.parameterEncoding = AFJSONParameterEncoding;
	[self setDefaultHeader:@"User-Agent" value:userAgent];
	[self setDefaultHeader:@"Accept" value:@"application/vnd.github.beta+json"];

	[AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:OCTClientNotModifiedStatusCode]];
	[AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/vnd.github.beta+json"]];
	[self registerHTTPOperationClass:AFJSONRequestOperation.class];

	return self;
}

+ (instancetype)unauthenticatedClientWithUser:(OCTUser *)user {
	NSParameterAssert(user != nil);

	OCTClient *client = [[self alloc] initWithServer:user.server];
	client.user = user;
	return client;
}

+ (instancetype)authenticatedClientWithUser:(OCTUser *)user token:(NSString *)token {
	NSParameterAssert(user != nil);
	NSParameterAssert(token != nil);

	OCTClient *client = [[self alloc] initWithServer:user.server];
	client.user = user;
	client.token = token;
	return client;
}

#pragma mark Authentication

+ (NSArray *)scopesArrayFromScopes:(OCTClientAuthorizationScopes)scopes {
	NSDictionary *scopeToScopeString = @{
		@(OCTClientAuthorizationScopesPublicReadOnly): @"",
		@(OCTClientAuthorizationScopesUserEmail): @"user:email",
		@(OCTClientAuthorizationScopesUserFollow): @"user:follow",
		@(OCTClientAuthorizationScopesUser): @"user",
		@(OCTClientAuthorizationScopesRepositoryStatus): @"repo:status",
		@(OCTClientAuthorizationScopesPublicRepository): @"public_repo",
		@(OCTClientAuthorizationScopesRepository): @"repo",
		@(OCTClientAuthorizationScopesRepositoryDelete): @"delete_repo",
		@(OCTClientAuthorizationScopesNotifications): @"notifications",
		@(OCTClientAuthorizationScopesGist): @"gist",
	};

	return [[[[scopeToScopeString.rac_keySequence
		filter:^ BOOL (NSNumber *scopeValue) {
			OCTClientAuthorizationScopes scope = scopeValue.unsignedIntegerValue;
			return (scopes & scope) != 0;
		}]
		map:^(NSNumber *scopeValue) {
			return scopeToScopeString[scopeValue];
		}]
		filter:^ BOOL (NSString *scopeString) {
			return scopeString.length > 0;
		}]
		array];
}

+ (RACSignal *)signInAsUser:(OCTUser *)user password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes {
	NSParameterAssert(user != nil);
	NSParameterAssert(password != nil);

	NSString *clientID = self.class.clientID;
	NSString *clientSecret = self.class.clientSecret;
	NSAssert(clientID != nil && clientSecret != nil, @"+setClientID:clientSecret: must be invoked before calling %@", NSStringFromSelector(_cmd));

	OCTClient *client = [self unauthenticatedClientWithUser:user];

	return [[[[[[[[RACSignal
		defer:^{
			[client setAuthorizationHeaderWithUsername:user.login password:password];

			NSString *path = [NSString stringWithFormat:@"authorizations/clients/%@", clientID];
			NSDictionary *params = @{
				@"scopes": [self scopesArrayFromScopes:scopes],
				@"client_secret": clientSecret,
			};

			NSMutableURLRequest *request = [client requestWithMethod:@"PUT" path:path parameters:params];
			request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
			if (oneTimePassword != nil) [request setValue:oneTimePassword forHTTPHeaderField:OCTClientOneTimePasswordHeaderField];

			return [client enqueueRequest:request resultClass:OCTAuthorization.class];
		}]
		catch:^(NSError *error) {
			NSNumber *statusCode = error.userInfo[OCTClientErrorHTTPStatusCodeKey];

			// 404s mean we tried to authorize in an unsupported way.
			if (statusCode.integerValue == 404) {
				NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
				userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"The server's version is unsupported.", @"");
				userInfo[NSUnderlyingErrorKey] = error;

				error = [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorUnsupportedServer userInfo:userInfo];
			}

			return [RACSignal error:error];
		}]
		oct_parsedResults]
		map:^(OCTAuthorization *authorization) {
			return [authorization.token copy];
		}]
		doNext:^(NSString *token) {
			client.token = token;
		}]
		mapReplace:client]
		replayLazily]
		setNameWithFormat:@"+signInAsUser: %@ password:oneTimePassword:scopes:", user];
}

+ (RACSignal *)signInToServerUsingWebBrowser:(OCTServer *)server callbackURL:(NSURL *)callbackURL scopes:(OCTClientAuthorizationScopes)scopes {
	NSParameterAssert(server != nil);
	NSParameterAssert(callbackURL != nil);

	NSString *clientID = self.class.clientID;
	NSString *clientSecret = self.class.clientSecret;
	NSAssert(clientID != nil && clientSecret != nil, @"+setClientID:clientSecret: must be invoked before calling %@", NSStringFromSelector(_cmd));

	OCTClient *client = [[self alloc] initWithServer:server];

	return [[[[[[[[[[self
		authorizeWithServerUsingWebBrowser:server callbackURL:callbackURL scopes:scopes clientID:clientID clientSecret:clientSecret]
		flattenMap:^(NSString *temporaryCode) {
			NSDictionary *params = @{
				@"client_id": clientID,
				@"client_secret": clientSecret,
				@"code": temporaryCode
			};

			NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
			request.URL = [NSURL URLWithString:@"login/oauth/access_token" relativeToURL:server.baseWebURL];
			request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
			return [client enqueueRequest:request resultClass:OCTAccessToken.class];
		}]
		oct_parsedResults]
		map:^(OCTAccessToken *accessToken) {
			return [accessToken.token copy];
		}]
		doNext:^(NSString *token) {
			client.token = token;
		}]
		then:^{
			return [client fetchUserInfo];
		}]
		doNext:^(OCTUser *user) {
			client.user = user;
		}]
		mapReplace:client]
		replayLazily]
		setNameWithFormat:@"+signInToServerUsingWebBrowser: %@ callbackURL: %@ scopes:", server, callbackURL];
}

+ (RACSignal *)authorizeWithServerUsingWebBrowser:(OCTServer *)server callbackURL:(NSURL *)callbackURL scopes:(OCTClientAuthorizationScopes)scopes clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
	NSParameterAssert(server != nil);
	NSParameterAssert(callbackURL != nil);

	return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
		CFRelease(uuid);

		// For any matching callback URL, send the temporary code to our
		// subscriber.
		//
		// This should be set up before opening the URL below, or we may
		// miss values on self.callbackURLs.
		RACDisposable *callbackDisposable = [[[[self.callbackURLs
			map:^(NSURL *URL) {
				return callbackURL.URLByStandardizingPath;
			}]
			filter:^(NSURL *URL) {
				NSURL *standardizedCallbackURL = callbackURL.URLByStandardizingPath;
				if (![URL.scheme isEqual:standardizedCallbackURL.scheme]) return NO;
				if (![URL.host isEqual:standardizedCallbackURL.host]) return NO;
				if (![URL.path isEqual:standardizedCallbackURL.path]) return NO;

				return YES;
			}]
			flattenMap:^(NSURL *URL) {
				NSArray *queryComponents = [URL.query componentsSeparatedByString:@"&"];
				NSMutableDictionary *queryArguments = [[NSMutableDictionary alloc] initWithCapacity:queryComponents.count];
				for (NSString *component in queryComponents) {
					NSArray *parts = [component componentsSeparatedByString:@"="];

					NSString *key = [parts.mtl_firstObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					id value = [parts.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ?: NSNull.null;
					queryArguments[key] = value;
				}

				if ([queryArguments[@"state"] isEqual:uuidString]) {
					return [RACSignal return:queryArguments[@"code"]];
				} else {
					return [RACSignal empty];
				}
			}]
			subscribe:subscriber];

		NSString *scope = [[self scopesArrayFromScopes:scopes] componentsJoinedByString:@","];
		CFStringRef redirectURLString = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)callbackURL.absoluteString, NULL, CFSTR(":/?&=@"), kCFStringEncodingUTF8);

		NSString *relativeString = [NSString stringWithFormat:@"login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&state=%@", clientID, CFBridgingRelease(redirectURLString), scope, uuidString];
		NSURL *webURL = [NSURL URLWithString:[relativeString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:server.baseWebURL];

		BOOL success;

		#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
		success = [UIApplication.sharedApplication openURL:webURL];
		#else
		success = [NSWorkspace.sharedWorkspace openURL:webURL];
		#endif

		if (!success) {
			[subscriber sendError:[NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorOpeningBrowser userInfo:@{
				NSLocalizedDescriptionKey: NSLocalizedString(@"Could not open web browser", nil),
				NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please make sure you have a default web browser set.", nil),
				NSURLErrorKey: webURL
			}]];
		}

		return callbackDisposable;
	}] setNameWithFormat:@"+authorizeWithServerUsingWebBrowser: %@ callbackURL: %@ scopes:", server, callbackURL];
}

+ (void)handleCallbackURL:(NSURL *)callbackURL {
	NSParameterAssert(callbackURL != nil);
	[self.callbackURLs sendNext:callbackURL];
}

#pragma mark Request Creation

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag {
	NSParameterAssert(method != nil);
	
	if ([method isEqualToString:@"GET"]) {
		parameters = [parameters ?: [NSDictionary dictionary] mtl_dictionaryByAddingEntriesFromDictionary:@{
			@"per_page": @100
		}];
	}

	NSMutableURLRequest *request = [self requestWithMethod:method path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:parameters];
	if (etag != nil) {
		[request setValue:etag forHTTPHeaderField:@"If-None-Match"];

		// If an etag is specified, we want 304 responses to be treated as 304s,
		// not served from NSURLCache with a status of 200.
		request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	}

	return request;
}

#pragma mark Request Enqueuing

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass {
	return [self enqueueRequest:request resultClass:resultClass fetchAllPages:YES];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass fetchAllPages:(BOOL)fetchAllPages {
	RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
			if (NSProcessInfo.processInfo.environment[OCTClientResponseLoggingEnvironmentKey] != nil) {
				NSLog(@"%@ %@ %@ => %li %@:\n%@", request.HTTPMethod, request.URL, request.allHTTPHeaderFields, (long)operation.response.statusCode, operation.response.allHeaderFields, responseObject);
			}

			if (operation.response.statusCode == OCTClientNotModifiedStatusCode) {
				// No change in the data.
				[subscriber sendCompleted];
				return;
			}

			RACSignal *thisPageSignal = [[self parsedResponseOfClass:resultClass fromJSON:responseObject]
				map:^(id parsedResult) {
					OCTResponse *response = [[OCTResponse alloc] initWithHTTPURLResponse:operation.response parsedResult:parsedResult];
					NSAssert(response != nil, @"Could not create OCTResponse with response %@ and parsedResult %@", operation.response, parsedResult);

					return response;
				}];

			if (NSProcessInfo.processInfo.environment[OCTClientRateLimitLoggingEnvironmentKey] != nil) {
				__block BOOL loggedRemaining = NO;
				thisPageSignal = [thisPageSignal doNext:^(OCTResponse *response) {
					if (loggedRemaining) return;

					NSLog(@"%@ %@ => %li remaining calls: %li/%li", request.HTTPMethod, request.URL, (long)operation.response.statusCode, (long)response.remainingRequests, (long)response.maximumRequestsPerHour);
					loggedRemaining = YES;
				}];
			}
			
			RACSignal *nextPageSignal = [RACSignal empty];
			NSURL *nextPageURL = (fetchAllPages ? [self nextPageURLFromOperation:operation] : nil);
			if (nextPageURL != nil) {
				// If we got this far, the etag is out of date, so don't pass it on.
				NSMutableURLRequest *nextRequest = [request mutableCopy];
				nextRequest.URL = nextPageURL;

				nextPageSignal = [self enqueueRequest:nextRequest resultClass:resultClass fetchAllPages:YES];
			}

			[[thisPageSignal concat:nextPageSignal] subscribe:subscriber];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (NSProcessInfo.processInfo.environment[OCTClientResponseLoggingEnvironmentKey] != nil) {
				NSLog(@"%@ %@ %@ => FAILED WITH %li", request.HTTPMethod, request.URL, request.allHTTPHeaderFields, (long)operation.response.statusCode);
			}

			[subscriber sendError:[self.class errorFromRequestOperation:(AFJSONRequestOperation *)operation]];
		}];

		operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		[self enqueueHTTPRequestOperation:operation];

		return [RACDisposable disposableWithBlock:^{
			[operation cancel];
		}];
	}];
	
	return [[signal
		replayLazily]
		setNameWithFormat:@"-enqueueRequest: %@ resultClass: %@ fetchAllPages: %i", request, resultClass, (int)fetchAllPages];
}

- (RACSignal *)enqueueUserRequestWithMethod:(NSString *)method relativePath:(NSString *)relativePath parameters:(NSDictionary *)parameters resultClass:(Class)resultClass {
	NSParameterAssert(method != nil);
	NSAssert([relativePath isEqualToString:@""] || [relativePath hasPrefix:@"/"], @"%@ is not a valid relativePath, it must start with @\"/\", or equal @\"\"", relativePath);
	
	if (self.user == nil) return [RACSignal error:self.class.userRequiredError];
		
	NSString *path = (self.authenticated ? [NSString stringWithFormat:@"user%@", relativePath] : [NSString stringWithFormat:@"users/%@%@", self.user.login, relativePath]);
	NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters notMatchingEtag:nil];
	if (self.authenticated) request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	
	return [self enqueueRequest:request resultClass:resultClass];
}

#pragma mark Pagination

- (NSURL *)nextPageURLFromOperation:(AFHTTPRequestOperation *)operation {
	NSDictionary *header = operation.response.allHeaderFields;
	NSString *linksString = header[@"Link"];
	if (linksString.length < 1) return nil;

	NSError *error = nil;
	NSRegularExpression *relPattern = [NSRegularExpression regularExpressionWithPattern:@"rel=\\\"?([^\\\"]+)\\\"?" options:NSRegularExpressionCaseInsensitive error:&error];
	NSAssert(relPattern != nil, @"Error constructing regular expression pattern: %@", error);

	NSMutableCharacterSet *whitespaceAndBracketCharacterSet = [NSCharacterSet.whitespaceCharacterSet mutableCopy];
	[whitespaceAndBracketCharacterSet addCharactersInString:@"<>"];
	
	NSArray *links = [linksString componentsSeparatedByString:@","];
	for (NSString *link in links) {
		NSRange semicolonRange = [link rangeOfString:@";"];
		if (semicolonRange.location == NSNotFound) continue;

		NSString *URLString = [[link substringToIndex:semicolonRange.location] stringByTrimmingCharactersInSet:whitespaceAndBracketCharacterSet];
		if (URLString.length == 0) continue;

		NSTextCheckingResult *result = [relPattern firstMatchInString:link options:0 range:NSMakeRange(0, link.length)];
		if (result == nil) continue;

		NSString *type = [link substringWithRange:[result rangeAtIndex:1]];
		if (![type isEqualToString:@"next"]) continue;

		return [NSURL URLWithString:URLString];
	}
	
	return nil;
}

#pragma mark Parsing

- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not parse the service response.", @"");

	if (localizedFailureReason != nil) {
		userInfo[NSLocalizedFailureReasonErrorKey] = localizedFailureReason;
	}

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorJSONParsingFailed userInfo:userInfo];
}

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject {
	NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:MTLModel.class]);

	return [RACSignal createSignal:^ id (id<RACSubscriber> subscriber) {
		void (^parseJSONDictionary)(NSDictionary *) = ^(NSDictionary *JSONDictionary) {
			if (resultClass == nil) {
				[subscriber sendNext:JSONDictionary];
				return;
			}

			NSError *error = nil;
			OCTObject *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&error];
			if (parsedObject == nil) {
				// Don't treat "no class found" errors as real parsing failures.
				// In theory, this makes parsing code forward-compatible with
				// API additions.
				if (![error.domain isEqual:MTLJSONAdapterErrorDomain] || error.code != MTLJSONAdapterErrorNoClassFound) {
					[subscriber sendError:error];
				}

				return;
			}

			NSAssert([parsedObject isKindOfClass:OCTObject.class], @"Parsed model object is not an OCTObject: %@", parsedObject);

			// Record the server that this object has come from.
			parsedObject.baseURL = self.baseURL;
			[subscriber sendNext:parsedObject];
		};

		if ([responseObject isKindOfClass:NSArray.class]) {
			for (NSDictionary *JSONDictionary in responseObject) {
				if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
					NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Invalid JSON array element: %@", @""), JSONDictionary];
					[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
					return nil;
				}

				parseJSONDictionary(JSONDictionary);
			}

			[subscriber sendCompleted];
		} else if ([responseObject isKindOfClass:NSDictionary.class]) {
			parseJSONDictionary(responseObject);
			[subscriber sendCompleted];
		} else if (responseObject != nil) {
			NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Response wasn't an array or dictionary (%@): %@", @""), [responseObject class], responseObject];
			[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
		}

		return nil;
	}];
}

#pragma mark Error Handling

+ (NSString *)errorMessageFromErrorDictionary:(NSDictionary *)errorDictionary {
	NSString *message = errorDictionary[@"message"];
	NSString *resource = errorDictionary[@"resource"];
	if (message != nil) {
		return [NSString stringWithFormat:NSLocalizedString(@"• %@ %@.", @""), resource, message];
	} else {
		NSString *field = errorDictionary[@"field"];
		NSString *codeType = errorDictionary[@"code"];

		NSString * (^localizedErrorMessage)(NSString *) = ^(NSString *message) {
			return [NSString stringWithFormat:message, resource, field];
		};
		
		NSString *codeString = localizedErrorMessage(@"%@ %@ is missing");
		if ([codeType isEqual:@"missing"]) {
			codeString = localizedErrorMessage(NSLocalizedString(@"%@ %@ does not exist", @""));
		} else if ([codeType isEqual:@"missing_field"]) {
			codeString = localizedErrorMessage(NSLocalizedString(@"%@ %@ is missing", @""));
		} else if ([codeType isEqual:@"invalid"]) {
			codeString = localizedErrorMessage(NSLocalizedString(@"%@ %@ is invalid", @""));
		} else if ([codeType isEqual:@"already_exists"]) {
			codeString = localizedErrorMessage(NSLocalizedString(@"%@ %@ already exists", @""));
		}

		return [NSString stringWithFormat:@"• %@.", codeString];
	}
}

+ (NSError *)errorFromRequestOperation:(AFJSONRequestOperation *)operation {
	NSParameterAssert(operation != nil);
	
	NSInteger HTTPCode = operation.response.statusCode;
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	NSInteger errorCode = OCTClientErrorServiceRequestFailed;

	NSDictionary *responseDictionary = nil;
	if ([operation.responseJSON isKindOfClass:NSDictionary.class]) {
		responseDictionary = operation.responseJSON;
	} else {
		NSLog(@"Unexpected JSON for error response: %@", operation.responseJSON);
	}

	NSString *message = responseDictionary[@"message"];
	
	if (HTTPCode == 401) {
		NSError *errorTemplate = self.class.authenticationRequiredError;

		errorCode = errorTemplate.code;
		NSString *OTPHeader = operation.response.allHeaderFields[OCTClientOneTimePasswordHeaderField];
		// E.g., "required; sms"
		NSArray *segments = [OTPHeader componentsSeparatedByString:@";"];
		if (segments.count == 2) {
			NSString *status = [segments[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
			NSString *medium = [segments[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
			if ([status.lowercaseString isEqual:@"required"]) {
				errorCode = OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired;
				NSDictionary *mediumStringToWrappedMedium = @{
					@"sms": @(OCTClientOneTimePasswordMediumSMS),
					@"app": @(OCTClientOneTimePasswordMediumApp),
				};
				NSNumber *wrappedMedium = mediumStringToWrappedMedium[medium.lowercaseString];
				if (wrappedMedium != nil) userInfo[OCTClientErrorOneTimePasswordMediumKey] = wrappedMedium;
			}
		}

		[userInfo addEntriesFromDictionary:errorTemplate.userInfo];
	} else if (HTTPCode == 400) {
		errorCode = OCTClientErrorBadRequest;
		if (message != nil) userInfo[NSLocalizedDescriptionKey] = message;
	} else if (HTTPCode == 422) {
		errorCode = OCTClientErrorServiceRequestFailed;
		
		NSArray *errorDictionaries = responseDictionary[@"errors"];
		if ([errorDictionaries isKindOfClass:NSArray.class]) {
			NSMutableArray *errors = [NSMutableArray arrayWithCapacity:errorDictionaries.count];
			for (NSDictionary *errorDictionary in errorDictionaries) {
				NSString *message = [self errorMessageFromErrorDictionary:errorDictionary];
				if (message == nil) continue;
				
				[errors addObject:message];
			}

			userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:NSLocalizedString(@"%@:\n\n%@", @""), message, [errors componentsJoinedByString:@"\n"]];
		}
	} else if (operation.error != nil) {
		errorCode = OCTClientErrorConnectionFailed;
		if ([operation.error.domain isEqual:NSURLErrorDomain]) {
			userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"There was a problem connecting to the server.", @"");
		} else {
			NSString *errorDescription = operation.error.userInfo[NSLocalizedDescriptionKey];
			if (errorDescription != nil) userInfo[NSLocalizedDescriptionKey] = errorDescription;
		}
	}

	if (userInfo[NSLocalizedDescriptionKey] == nil) {
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"The universe has collapsed.", @"");
	}

	userInfo[OCTClientErrorHTTPStatusCodeKey] = @(HTTPCode);
	if (operation.request.URL != nil) userInfo[OCTClientErrorRequestURLKey] = operation.request.URL;
	if (operation.error != nil) userInfo[NSUnderlyingErrorKey] = operation.error;
	
	return [NSError errorWithDomain:OCTClientErrorDomain code:errorCode userInfo:userInfo];
}

@end

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchUserStarredRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/starred" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	return [self createRepositoryWithName:name organization:nil team:nil description:description private:isPrivate];
}

@end

@implementation OCTClient (Organizations)

- (RACSignal *)fetchUserOrganizations {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/orgs" parameters:nil resultClass:OCTOrganization.class] oct_parsedResults];
}

- (RACSignal *)fetchOrganizationInfo:(OCTOrganization *)organization {
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@", organization.login] parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTOrganization.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization {
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/repos", organization.login] parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"name"] = name;
	options[@"private"] = @(isPrivate);

	if (description != nil) options[@"description"] = description;
	if (team != nil) options[@"team_id"] = team.objectID;
	
	NSString *path = (organization == nil ? @"user/repos" : [NSString stringWithFormat:@"orgs/%@/repos", organization.login]);
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:options notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchTeamsForOrganization:(OCTOrganization *)organization {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/teams", organization.login] parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTTeam.class] oct_parsedResults];
}

@end

@implementation OCTClient (Keys)

- (RACSignal *)fetchPublicKeys {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/keys" parameters:nil resultClass:OCTPublicKey.class] oct_parsedResults];
}

- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title {
	NSParameterAssert(key != nil);
	NSParameterAssert(title != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	OCTPublicKey *publicKey = [OCTPublicKey modelWithDictionary:@{
		@keypath(OCTPublicKey.new, publicKey): key,
		@keypath(OCTPublicKey.new, title): title,
	} error:NULL];
	
	NSURLRequest *request = [self requestWithMethod:@"POST" path:@"user/keys" parameters:[MTLJSONAdapter JSONDictionaryFromModel:publicKey] notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTPublicKey.class] oct_parsedResults];
}

@end

@implementation OCTClient (Events)

- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag {
	if (self.user == nil) return [RACSignal error:self.class.userRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"users/%@/received_events", self.user.login] parameters:nil notMatchingEtag:etag];
	
	return [self enqueueRequest:request resultClass:OCTEvent.class fetchAllPages:NO];
}

@end

@implementation OCTClient (Notifications)

- (RACSignal *)fetchNotificationsNotMatchingEtag:(NSString *)etag includeReadNotifications:(BOOL)includeRead updatedSince:(NSDate *)since {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"all"] = @(includeRead);

	if (since != nil) {
		parameters[@"since"] = [NSDateFormatter oct_stringFromDate:since];
	}
	NSURLRequest *request = [self requestWithMethod:@"GET" path:@"notifications" parameters:parameters notMatchingEtag:etag];
	return [self enqueueRequest:request resultClass:OCTNotification.class];
}

- (RACSignal *)markNotificationThreadAsReadAtURL:(NSURL *)threadURL {
	return [self patchThreadURL:threadURL withReadStatus:YES];
}

- (RACSignal *)patchThreadURL:(NSURL *)threadURL withReadStatus:(BOOL)read {
	NSParameterAssert(threadURL != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableURLRequest *request = [self requestWithMethod:@"PATCH" path:@"" parameters:@{ @"read": @(read) }];
	request.URL = threadURL;
	return [[self enqueueRequest:request resultClass:nil] ignoreValues];
}

- (RACSignal *)muteNotificationThreadAtURL:(NSURL *)threadURL {
	NSParameterAssert(threadURL != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:@"" parameters:@{ @"ignored": @YES }];
	request.URL = [threadURL URLByAppendingPathComponent:@"subscription"];
	return [[self enqueueRequest:request resultClass:nil] ignoreValues];
}

@end

@implementation OCTClient (Repository)

- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	relativePath = relativePath ?: @"";
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/contents/%@", repository.ownerLogin, repository.name, relativePath];
	
	NSDictionary *parameters = nil;
	if (reference.length > 0) {
		parameters = @{ @"ref": reference };
	}
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/readme", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository recursive:(BOOL)recursive {
	NSParameterAssert(repository != nil);

	if (reference == nil) reference = @"HEAD";

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees/%@", repository.ownerLogin, repository.name, reference];
	NSDictionary *parameters;
	if (recursive) parameters = @{ @"recursive": @1 };

	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	return [[self enqueueRequest:request resultClass:OCTTree.class] oct_parsedResults];
}

@end

@implementation OCTClient (Gist)

- (RACSignal *)fetchGists {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:@"gists" parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

- (RACSignal *)applyEdit:(OCTGistEdit *)edit toGist:(OCTGist *)gist {
	NSParameterAssert(edit != nil);
	NSParameterAssert(gist != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
	NSURLRequest *request = [self requestWithMethod:@"PATCH" path:[NSString stringWithFormat:@"gists/%@", gist.objectID] parameters:parameters notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

- (RACSignal *)createGistWithEdit:(OCTGistEdit *)edit {
	NSParameterAssert(edit != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:@"gists" parameters:parameters notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTGist.class] oct_parsedResults];
}

@end
