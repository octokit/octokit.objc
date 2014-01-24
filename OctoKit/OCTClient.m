//
//  OCTClient.m
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTClient.h"
#import "OCTClient+Private.h"
#import "OCTClient+User.h"
#import "NSURL+OCTQueryAdditions.h"
#import "OCTAccessToken.h"
#import "OCTAuthorization.h"
#import "OCTObject+Private.h"
#import "OCTResponse.h"
#import "OCTServer.h"
#import "OCTServerMetadata.h"
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
const NSInteger OCTClientErrorOpeningBrowserFailed = 673;
const NSInteger OCTClientErrorRequestForbidden = 674;
const NSInteger OCTClientErrorTokenAuthenticationUnsupported = 675;

NSString * const OCTClientErrorRequestURLKey = @"OCTClientErrorRequestURLKey";
NSString * const OCTClientErrorHTTPStatusCodeKey = @"OCTClientErrorHTTPStatusCodeKey";
NSString * const OCTClientErrorOneTimePasswordMediumKey = @"OCTClientErrorOneTimePasswordMediumKey";
NSString * const OCTClientErrorOAuthScopesStringKey = @"OCTClientErrorOAuthScopesStringKey";

NSString * const OCTClientAPIVersion = @"v3";

static const NSInteger OCTClientNotModifiedStatusCode = 304;
static NSString * const OCTClientOneTimePasswordHeaderField = @"X-GitHub-OTP";
static NSString * const OCTClientOAuthScopesHeaderField = @"X-OAuth-Scopes";

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
		[self setAuthorizationHeaderWithUsername:token password:@"x-oauth-basic"];
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
		NSLocalizedDescriptionKey: NSLocalizedString(@"Sign In Required", @""),
		NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"You must sign in to access user information.", @""),
	};

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorAuthenticationFailed userInfo:userInfo];
}

+ (NSError *)unsupportedVersionError {
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: NSLocalizedString(@"Unsupported Server", @""),
		NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The request failed because the server is out of date.", @""),
	};

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorUnsupportedServer userInfo:userInfo];
}

+ (NSError *)tokenUnsupportedError {
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: NSLocalizedString(@"Password Required", @""),
		NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"You must sign in with a password. Token authentication is not supported.", @""),
	};

	return [NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorTokenAuthenticationUnsupported userInfo:userInfo];
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
	if (userAgent != nil) [self setDefaultHeader:@"User-Agent" value:userAgent];

	[AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:OCTClientNotModifiedStatusCode]];

	NSString *contentType = [NSString stringWithFormat:@"application/vnd.github.%@+json", OCTClientAPIVersion];
	[self setDefaultHeader:@"Accept" value:contentType];
	[AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:contentType]];

	self.parameterEncoding = AFJSONParameterEncoding;
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
			[client setAuthorizationHeaderWithUsername:user.rawLogin password:password];

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
			if (statusCode.integerValue == 404) {
				if (error.userInfo[OCTClientErrorOAuthScopesStringKey] != nil) {
					error = self.class.tokenUnsupportedError;
				} else {
					error = self.class.unsupportedVersionError;
				}
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

+ (RACSignal *)signInToServerUsingWebBrowser:(OCTServer *)server scopes:(OCTClientAuthorizationScopes)scopes {
	NSParameterAssert(server != nil);

	NSString *clientID = self.class.clientID;
	NSString *clientSecret = self.class.clientSecret;
	NSAssert(clientID != nil && clientSecret != nil, @"+setClientID:clientSecret: must be invoked before calling %@", NSStringFromSelector(_cmd));

	OCTClient *client = [[self alloc] initWithServer:server];

	return [[[[[[[[[[self
		authorizeWithServerUsingWebBrowser:server scopes:scopes]
		flattenMap:^(NSString *temporaryCode) {
			NSDictionary *params = @{
				@"client_id": clientID,
				@"client_secret": clientSecret,
				@"code": temporaryCode
			};

			// We're using -requestWithMethod: for its parameter encoding and
			// User-Agent behavior, but we'll replace the key properties so we
			// can POST to another host.
			NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"" parameters:params];
			request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
			request.URL = [NSURL URLWithString:@"login/oauth/access_token" relativeToURL:server.baseWebURL];

			// The `Accept` string we normally use (where we specify the beta
			// version of the API) doesn't work for this endpoint. Just plain
			// JSON.
			[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

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
		setNameWithFormat:@"+signInToServerUsingWebBrowser: %@ scopes:", server];
}

+ (RACSignal *)authorizeWithServerUsingWebBrowser:(OCTServer *)server scopes:(OCTClientAuthorizationScopes)scopes {
	NSParameterAssert(server != nil);

	NSString *clientID = self.class.clientID;
	NSAssert(clientID != nil, @"+setClientID:clientSecret: must be invoked before calling %@", NSStringFromSelector(_cmd));

	return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
		CFRelease(uuid);

		// For any matching callback URL, send the temporary code to our
		// subscriber.
		//
		// This should be set up before opening the URL below, or we may
		// miss values on self.callbackURLs.
		RACDisposable *callbackDisposable = [[[self.callbackURLs
			flattenMap:^(NSURL *URL) {
				NSDictionary *queryArguments = URL.oct_queryArguments;
				if ([queryArguments[@"state"] isEqual:uuidString]) {
					return [RACSignal return:queryArguments[@"code"]];
				} else {
					return [RACSignal empty];
				}
			}]
			take:1]
			subscribe:subscriber];

		NSString *scope = [[self scopesArrayFromScopes:scopes] componentsJoinedByString:@","];

		// Trim trailing slashes from URL entered by the user, so we don't open
		// their web browser to a URL that contains empty path components.
		NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
		NSString *baseURLString = [server.baseWebURL.absoluteString stringByTrimmingCharactersInSet:slashSet];

		NSString *URLString = [[NSString alloc] initWithFormat:@"%@/login/oauth/authorize?client_id=%@&scope=%@&state=%@", baseURLString, clientID, scope, uuidString];
		NSURL *webURL = [NSURL URLWithString:URLString];

		if (![self openURL:webURL]) {
			[subscriber sendError:[NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorOpeningBrowserFailed userInfo:@{
				NSLocalizedDescriptionKey: NSLocalizedString(@"Could not open web browser", nil),
				NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please make sure you have a default web browser set.", nil),
				NSURLErrorKey: webURL
			}]];
		}

		return callbackDisposable;
	}] setNameWithFormat:@"+authorizeWithServerUsingWebBrowser: %@ scopes:", server];
}

+ (RACSignal *)fetchMetadataForServer:(OCTServer *)server {
	NSParameterAssert(server != nil);

	OCTClient *client = [[self alloc] initWithServer:server];
	NSURLRequest *request = [client requestWithMethod:@"GET" path:@"meta" parameters:nil notMatchingEtag:nil];

	return [[[[client
		enqueueRequest:request resultClass:OCTServerMetadata.class]
		catch:^(NSError *error) {
			NSNumber *statusCode = error.userInfo[OCTClientErrorHTTPStatusCodeKey];
			if (statusCode.integerValue == 404) error = self.class.unsupportedVersionError;

			return [RACSignal error:error];
		}]
		oct_parsedResults]
		setNameWithFormat:@"+fetchMetadataForServer: %@", server];
}

+ (BOOL)openURL:(NSURL *)URL {
	NSParameterAssert(URL != nil);

	#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	return [UIApplication.sharedApplication openURL:URL];
	#else
	return [NSWorkspace.sharedWorkspace openURL:URL];
	#endif
}

+ (void)completeSignInWithCallbackURL:(NSURL *)callbackURL {
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

- (RACSignal *)enqueueRequest:(NSURLRequest *)request fetchAllPages:(BOOL)fetchAllPages {
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
			
			RACSignal *nextPageSignal = [RACSignal empty];
			NSURL *nextPageURL = (fetchAllPages ? [self nextPageURLFromOperation:operation] : nil);
			if (nextPageURL != nil) {
				// If we got this far, the etag is out of date, so don't pass it on.
				NSMutableURLRequest *nextRequest = [request mutableCopy];
				nextRequest.URL = nextPageURL;

				nextPageSignal = [self enqueueRequest:nextRequest fetchAllPages:YES];
			}

			[[[RACSignal
				return:RACTuplePack(operation.response, responseObject)]
				concat:nextPageSignal]
				subscribe:subscriber];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (NSProcessInfo.processInfo.environment[OCTClientResponseLoggingEnvironmentKey] != nil) {
				NSLog(@"%@ %@ %@ => FAILED WITH %li", request.HTTPMethod, request.URL, request.allHTTPHeaderFields, (long)operation.response.statusCode);
			}

			[subscriber sendError:[self.class errorFromRequestOperation:operation]];
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
		setNameWithFormat:@"-enqueueRequest: %@ fetchAllPages: %i", request, (int)fetchAllPages];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass {
	return [self enqueueRequest:request resultClass:resultClass fetchAllPages:YES];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass fetchAllPages:(BOOL)fetchAllPages {
	return [[[self
		enqueueRequest:request fetchAllPages:fetchAllPages]
		reduceEach:^(NSHTTPURLResponse *response, id responseObject) {
			__block BOOL loggedRemaining = NO;

			return [[[self
				parsedResponseOfClass:resultClass fromJSON:responseObject]
				map:^(id parsedResult) {
					OCTResponse *parsedResponse = [[OCTResponse alloc] initWithHTTPURLResponse:response parsedResult:parsedResult];
					NSAssert(parsedResponse != nil, @"Could not create OCTResponse with response %@ and parsedResult %@", response, parsedResult);

					return parsedResponse;
				}]
				doNext:^(OCTResponse *parsedResponse) {
					if (NSProcessInfo.processInfo.environment[OCTClientRateLimitLoggingEnvironmentKey] == nil) return;
					if (loggedRemaining) return;

					NSLog(@"%@ => %li remaining calls: %li/%li", response.URL, (long)response.statusCode, (long)parsedResponse.remainingRequests, (long)parsedResponse.maximumRequestsPerHour);
					loggedRemaining = YES;
				}];
		}]
		concat];
}

- (RACSignal *)enqueueUserRequestWithMethod:(NSString *)method relativePath:(NSString *)relativePath parameters:(NSDictionary *)parameters resultClass:(Class)resultClass {
	NSParameterAssert(method != nil);
	NSAssert([relativePath isEqualToString:@""] || [relativePath hasPrefix:@"/"], @"%@ is not a valid relativePath, it must start with @\"/\", or equal @\"\"", relativePath);

	NSString *path;
	if (self.authenticated) {
		path = [NSString stringWithFormat:@"user%@", relativePath];
	} else if (self.user != nil) {
		path = [NSString stringWithFormat:@"users/%@%@", self.user.login, relativePath];
	} else {
		return [RACSignal error:self.class.userRequiredError];
	}
		
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

+ (NSString *)defaultErrorMessageFromRequestOperation:(AFHTTPRequestOperation *)operation {
	NSParameterAssert(operation != nil);

	NSDictionary *responseDictionary = nil;
	if ([operation isKindOfClass:AFJSONRequestOperation.class]) {
		id JSON = [(AFJSONRequestOperation *)operation responseJSON];
		if ([JSON isKindOfClass:NSDictionary.class]) {
			responseDictionary = JSON;
		} else {
			NSLog(@"Unexpected JSON for error response: %@", JSON);
		}
	}

	NSString *errorDescription = responseDictionary[@"message"] ?: operation.error.localizedDescription;
	if (errorDescription == nil) {
		if ([operation.error.domain isEqual:NSURLErrorDomain]) {
			errorDescription = NSLocalizedString(@"There was a problem connecting to the server.", @"");
		} else {
			errorDescription = NSLocalizedString(@"The universe has collapsed.", @"");
		}
	}
	
	NSArray *errorDictionaries = responseDictionary[@"errors"];
	if ([errorDictionaries isKindOfClass:NSArray.class]) {
		NSString *errors = [[[errorDictionaries.rac_sequence
			flattenMap:^(NSDictionary *errorDictionary) {
				NSString *message = [self errorMessageFromErrorDictionary:errorDictionary];
				if (message == nil) {
					return [RACSequence empty];
				} else {
					return [RACSequence return:message];
				}
			}]
			array]
			componentsJoinedByString:@"\n"];

		errorDescription = [NSString stringWithFormat:NSLocalizedString(@"%@:\n\n%@", @""), errorDescription, errors];
	}
	
	return errorDescription;
}

+ (NSNumber *)oneTimePasswordMediumFromHeader:(NSString *)OTPHeader {
	// E.g., "required; sms"
	NSArray *segments = [OTPHeader componentsSeparatedByString:@";"];
	if (segments.count != 2) return nil;

	NSString *status = [segments[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	NSString *medium = [segments[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	if ([status caseInsensitiveCompare:@"required"] != NSOrderedSame) return nil;

	NSDictionary *mediumStringToWrappedMedium = @{
		@"sms": @(OCTClientOneTimePasswordMediumSMS),
		@"app": @(OCTClientOneTimePasswordMediumApp),
	};

	return mediumStringToWrappedMedium[medium.lowercaseString];
}

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation {
	NSParameterAssert(operation != nil);
	
	NSInteger HTTPCode = operation.response.statusCode;
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	NSInteger errorCode = OCTClientErrorConnectionFailed;

	userInfo[NSLocalizedDescriptionKey] = [self defaultErrorMessageFromRequestOperation:operation];
	
	switch (HTTPCode) {
		case 401: {
			NSError *errorTemplate = self.class.authenticationRequiredError;

			errorCode = errorTemplate.code;
			[userInfo addEntriesFromDictionary:errorTemplate.userInfo];

			NSNumber *wrappedMedium = [self oneTimePasswordMediumFromHeader:operation.response.allHeaderFields[OCTClientOneTimePasswordHeaderField]];
			if (wrappedMedium != nil) {
				errorCode = OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired;
				userInfo[OCTClientErrorOneTimePasswordMediumKey] = wrappedMedium;
			}

			break;
		}

		case 400:
			errorCode = OCTClientErrorBadRequest;
			break;

		case 403:
			errorCode = OCTClientErrorRequestForbidden;
			break;

		case 422:
			errorCode = OCTClientErrorServiceRequestFailed;
			break;
	}

	userInfo[OCTClientErrorHTTPStatusCodeKey] = @(HTTPCode);
	if (operation.request.URL != nil) userInfo[OCTClientErrorRequestURLKey] = operation.request.URL;
	if (operation.error != nil) userInfo[NSUnderlyingErrorKey] = operation.error;

	NSString *scopes = operation.response.allHeaderFields[OCTClientOAuthScopesHeaderField];
	if (scopes != nil) userInfo[OCTClientErrorOAuthScopesStringKey] = scopes;
	
	return [NSError errorWithDomain:OCTClientErrorDomain code:errorCode userInfo:userInfo];
}

@end
