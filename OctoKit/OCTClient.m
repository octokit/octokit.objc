//
//  OCTClient.m
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTClient.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"
#import "OCTEvent.h"
#import "OCTObject+Private.h"
#import "OCTOrganization.h"
#import "OCTPublicKey.h"
#import "OCTRepository.h"
#import "OCTResponse.h"
#import "OCTServer.h"
#import "OCTTeam.h"
#import "OCTUser.h"
#import "OCTNotification.h"
#import "RACSignal+OCTClientAdditions.h"

NSString * const OCTClientErrorDomain = @"OCTClientErrorDomain";
const NSInteger OCTClientErrorAuthenticationFailed = 666;
const NSInteger OCTClientErrorServiceRequestFailed = 667;
const NSInteger OCTClientErrorConnectionFailed = 668;
const NSInteger OCTClientErrorJSONParsingFailed = 669;
const NSInteger OCTClientErrorBadRequest = 670;

NSString * const OCTClientErrorRequestURLKey = @"OCTClientErrorRequestURLKey";
NSString * const OCTClientErrorHTTPStatusCodeKey = @"OCTClientErrorHTTPStatusCodeKey";

static const NSInteger OCTClientNotModifiedStatusCode = 304;

@interface OCTClient ()

@property (nonatomic, strong, readwrite) OCTUser *user;
@property (nonatomic, getter = isAuthenticated, readwrite) BOOL authenticated;

// An error indicating that a request required a valid user, but no `user`
// property was set.
+ (NSError *)userRequiredError;

// An error indicating that a request required authentication, but the client
// was not created with a password.
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

@end

@implementation OCTClient

#pragma mark Lifecycle

+ (instancetype)authenticatedClientWithUser:(OCTUser *)user password:(NSString *)password {
	NSParameterAssert(user != nil);
	NSParameterAssert(password != nil);

	OCTClient *client = [[self alloc] initWithServer:user.server];
	client.authenticated = YES;
	client.user = user;

	[client setAuthorizationHeaderWithUsername:user.login password:password];
	return client;
}

+ (instancetype)unauthenticatedClientWithUser:(OCTUser *)user {
	NSParameterAssert(user != nil);

	OCTClient *client = [[self alloc] initWithServer:user.server];
	client.user = user;
	return client;
}

- (id)initWithBaseURL:(NSURL *)url {
	NSAssert(NO, @"%@ must be initialized using -initWithServer:", self.class);
	return nil;
}

- (id)initWithServer:(OCTServer *)server {
	NSParameterAssert(server != nil);

	self = [super initWithBaseURL:server.APIEndpoint];
	if (self == nil) return nil;
	
	self.parameterEncoding = AFJSONParameterEncoding;
	[self registerHTTPOperationClass:AFJSONRequestOperation.class];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	[AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:OCTClientNotModifiedStatusCode]];

	return self;
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
			if (getenv("LOG_API_RESPONSES") != NULL) {
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
			[subscriber sendError:[self.class errorFromRequestOperation:(AFJSONRequestOperation *)operation]];
		}];

		operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		[self enqueueHTTPRequestOperation:operation];

		return [RACDisposable disposableWithBlock:^{
			[operation cancel];
		}];
	}];

	if (getenv("LOG_REMAINING_API_CALLS") != NULL) {
		// Avoid infinite recursion.
		if (![request.URL.path isEqualToString:@"rate_limit"]) {
			signal = [signal doCompleted:^{
				NSURLRequest *request = [self requestWithMethod:@"GET" path:@"rate_limit" parameters:nil notMatchingEtag:nil];
				[[self enqueueRequest:request resultClass:nil] subscribeNext:^(NSDictionary *dict) {
					NSLog(@"Remaining API calls: %@", dict[@"rate"][@"remaining"]);
				}];
			}];
		}
	}
	
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
	NSDictionary *responseDictionary = operation.responseJSON;
	NSString *message = responseDictionary[@"message"];
	
	if (HTTPCode == 401) {
		NSError *errorTemplate = self.class.authenticationRequiredError;

		errorCode = errorTemplate.code;
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

@end

@implementation OCTClient (User)

- (RACSignal *)fetchUserInfo {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"" parameters:nil resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
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
	return [[self enqueueRequest:request resultClass:nil] ignoreElements];
}

- (RACSignal *)muteNotificationThreadAtURL:(NSURL *)threadURL {
	NSParameterAssert(threadURL != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:@"" parameters:@{ @"ignored": @YES }];
	request.URL = [threadURL URLByAppendingPathComponent:@"subscription"];
	return [[self enqueueRequest:request resultClass:nil] ignoreElements];
}

@end
