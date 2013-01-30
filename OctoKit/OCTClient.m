//
//  OCTClient.m
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTClient.h"
#import "NSArray+OCTFlatteningAdditions.h"
#import "OCTEvent.h"
#import "OCTObject+Private.h"
#import "OCTOrg.h"
#import "OCTPublicKey.h"
#import "OCTRepository.h"
#import "OCTResponse.h"
#import "OCTServer.h"
#import "OCTTeam.h"
#import "OCTUser.h"

NSString * const OCTClientErrorDomain = @"OCTClientErrorDomain";
const NSInteger OCTClientErrorAuthenticationFailed = 666;
const NSInteger OCTClientErrorServiceRequestFailed = 667;
const NSInteger OCTClientErrorConnectionFailed = 668;
const NSInteger OCTClientErrorJSONParsingFailed = 669;
const NSInteger OCTClientErrorBadRequest = 670;

NSString * const OCTClientErrorRequestURLKey = @"OCTClientErrorRequestURLKey";
NSString * const OCTClientErrorHTTPStatusCodeKey = @"OCTClientErrorHTTPStatusCodeKey";

static const NSUInteger OCTClientNotModifiedStatusCode = 304;

@interface OCTClient ()

@property (nonatomic, strong) OCTUser *user;

@end


@implementation OCTClient

#pragma mark API

+ (OCTClient *)clientForUser:(OCTUser *)user {
	NSParameterAssert(user != nil);
	
	OCTClient *client = [[self alloc] initWithServer:user.server];
	client.user = user;
	return client;
}

- (id)initWithServer:(OCTServer *)server {
	self = [super initWithBaseURL:server.APIEndpoint];
	if(self == nil) return nil;
	
	self.parameterEncoding = AFJSONParameterEncoding;
	[self registerHTTPOperationClass:AFJSONRequestOperation.class];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	[AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:OCTClientNotModifiedStatusCode]];

	return self;
}

- (RACSignal *)login {
	return [[self enqueueRequestWithMethod:@"GET" path:@"user" parameters:nil resultClass:OCTUser.class] doNext:^(OCTUser *x) {
		x.password = self.user.password;
	}];
}

- (RACSignal *)fetchUserInfo {
	return [self enqueueRequestWithMethod:@"GET" path:@"user" parameters:nil resultClass:OCTUser.class];
}

- (RACSignal *)fetchUserRepos {
	return [self enqueueRequestWithMethod:@"GET" path:@"user/repos" parameters:nil resultClass:OCTRepository.class];
}

- (RACSignal *)fetchUserOrgs {
	return [self enqueueRequestWithMethod:@"GET" path:@"user/orgs" parameters:nil resultClass:OCTOrg.class];
}

- (RACSignal *)fetchOrgInfo:(OCTOrg *)org {
	return [self enqueueRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@", org.login] parameters:nil resultClass:OCTOrg.class];
}

- (RACSignal *)fetchReposForOrg:(OCTOrg *)org {
	return [self enqueueRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/repos", org.login] parameters:nil resultClass:OCTRepository.class];
}

- (RACSignal *)fetchPublicKeys {
	return [self enqueueRequestWithMethod:@"GET" path:@"user/keys" parameters:nil resultClass:OCTPublicKey.class];
}

- (RACSignal *)createRepoWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate {
	return [self createRepoWithName:name org:nil team:nil description:description private:isPrivate];
}

- (RACSignal *)createRepoWithName:(NSString *)name org:(OCTOrg *)org team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate {
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:name forKey:@"name"];
	if(description != nil) [options setObject:description forKey:@"description"];
	[options setObject:[NSNumber numberWithBool:isPrivate] forKey:@"private"];
	if (team != nil) options[@"team_id"] = team.objectID;
	
	NSString *path = org == nil ? @"user/repos" : [NSString stringWithFormat:@"orgs/%@/repos", org.login];
	return [self enqueueRequestWithMethod:@"POST" path:path parameters:options resultClass:OCTRepository.class];
}

- (RACSignal *)fetchTeamsForOrg:(OCTOrg *)org {
	return [self enqueueRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/teams", org.login] parameters:nil resultClass:OCTTeam.class];
}

- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title {
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:key forKey:@"key"];
	[options setObject:title forKey:@"title"];
	return [self enqueueRequestWithMethod:@"POST" path:@"user/keys" parameters:options resultClass:OCTPublicKey.class];
}

- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag {
	return [self enqueueConditionalRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"users/%@/received_events", self.user.login] parameters:nil notMatchingEtag:etag resultClass:OCTEvent.class fetchAllPages:NO];
}

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass {
	return [[self enqueueConditionalRequestWithMethod:method path:path parameters:parameters notMatchingEtag:nil resultClass:resultClass]
		map:^(OCTResponse *response) {
			return response.parsedResult;
		}];
}

- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag resultClass:(Class)resultClass {
	return [self enqueueConditionalRequestWithMethod:method path:path parameters:parameters notMatchingEtag:etag resultClass:resultClass fetchAllPages:YES];
}

- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag resultClass:(Class)resultClass fetchAllPages:(BOOL)fetchAllPages {
	NSParameterAssert(method != nil);
	
	NSMutableURLRequest *request = [self requestWithMethod:method path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:parameters];
	if (etag != nil) {
		[request setValue:etag forHTTPHeaderField:@"If-None-Match"];
	}

	return [self enqueueRequest:request resultClass:resultClass fetchAllPages:fetchAllPages];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass fetchAllPages:(BOOL)fetchAllPages {
	RACReplaySubject *subject = [RACReplaySubject subject];

	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		void (^sendResult)(id) = ^(id parsedResult) {
			OCTResponse *response = [[OCTResponse alloc] initWithHTTPURLResponse:operation.response parsedResult:parsedResult];
			NSAssert(response != nil, @"Could not create OCTResponse with response %@ and parsedResult %@", operation.response, parsedResult);

			[subject sendNext:response];
			[subject sendCompleted];
		};

		if (operation.response.statusCode == OCTClientNotModifiedStatusCode) {
			// No change in the data.
			[subject sendCompleted];
			return;
		}
		
		if (getenv("LOG_API_RESPONSES") != NULL) {
			NSLog(@"%@ %@ => %li %@:\n%@", request.HTTPMethod, request.URL, (long)operation.response.statusCode, operation.response.allHeaderFields, responseObject);
		}

		BOOL success = YES;
		id parsedResult = [self parseResponse:responseObject withResultClass:resultClass success:&success];
		if (!success) {
			NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse the service response.", @"") };
			[subject sendError:[NSError errorWithDomain:OCTClientErrorDomain code:OCTClientErrorJSONParsingFailed userInfo:userInfo]];
			return;
		}
		
		NSURL *nextPageURL = (fetchAllPages ? [self nextPageURLFromOperation:operation] : nil);
		if (nextPageURL != nil) {
			NSMutableURLRequest *nextRequest = [request mutableCopy];
			nextRequest.URL = nextPageURL;

			// If we got this far, the etag is out of date, so don't pass it on.
			RACSignal *nextPageResult = [self enqueueRequest:nextRequest resultClass:resultClass fetchAllPages:YES];
			[nextPageResult subscribeNext:^(OCTResponse *x) {
				NSMutableArray *accumulatedResult = [NSMutableArray array];
				[accumulatedResult addObject:parsedResult];
				[accumulatedResult addObject:x.parsedResult];
				
				sendResult(accumulatedResult.oct_flattenedArray);
			} error:^(NSError *error) {
				[subject sendError:error];
			}];
		} else {
			sendResult(parsedResult);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:[self.class errorFromRequestOperation:(AFJSONRequestOperation *)operation]];
	}];

	operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	[self enqueueHTTPRequestOperation:operation];

	if (getenv("LOG_REMAINING_API_CALLS") != NULL) {
		// Avoid infinite recursion.
		if (![request.URL.path isEqualToString:@"rate_limit"]) {
			[[subject sequenceNext:^{
				return [self enqueueRequestWithMethod:@"GET" path:@"rate_limit" parameters:nil resultClass:nil];
			}] subscribeNext:^(NSDictionary *dict) {
				NSLog(@"Remaining API calls: %@", dict[@"rate"][@"remaining"]);
			}];
		}
	}
	
	return [subject deliverOn:RACScheduler.mainThreadScheduler];
}

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

- (id)parseResponse:(id)responseObject withResultClass:(Class)resultClass success:(BOOL *)success {
	NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:MTLModel.class]);

	id parsedResult = nil;
	if(resultClass != nil) {
		if([responseObject isKindOfClass:NSArray.class]) {
			parsedResult = [NSMutableArray array];
			for(NSDictionary *info in responseObject) {
				if(![info isKindOfClass:NSDictionary.class]) {
					NSLog(@"Invalid array element type: %@", info);
					continue;
				}
				
				OCTObject *newObject = [resultClass modelWithExternalRepresentation:info];
				if (newObject == nil) continue;

				NSAssert([newObject isKindOfClass:OCTObject.class], @"Parsed model object is not a OCTObject: %@", newObject);

				// Record the server that this object has come from.
				newObject.baseURL = self.baseURL;
				[parsedResult addObject:newObject];
			}
		} else if([responseObject isKindOfClass:NSDictionary.class]) {
			parsedResult = [resultClass modelWithExternalRepresentation:responseObject];
		} else {
			NSLog(@"Response wasn't an array or dictionary (%@): %@", NSStringFromClass([responseObject class]), responseObject);
			if (success != NULL) *success = NO;
		}
	} else {
		parsedResult = responseObject;
	}

	// Record the server that this object has come from.
	if ([parsedResult isKindOfClass:OCTObject.class]) [parsedResult setBaseURL:self.baseURL];

	if (success != NULL) *success = YES;
	
	return parsedResult;
}

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
	// Trust the status code that everything's cool.
	if (HTTPCode == 200) return nil;
		
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	NSInteger errorCode = OCTClientErrorServiceRequestFailed;
	NSDictionary *responseDictionary = operation.responseJSON;
	NSString *message = responseDictionary[@"message"];
	
	if (HTTPCode == 401) {
		errorCode = OCTClientErrorAuthenticationFailed;
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Please login to use this end point.", @"");
	} else if (HTTPCode == 400) {
		errorCode = OCTClientErrorBadRequest;
		if (message != nil) userInfo[NSLocalizedDescriptionKey] = message;
	} else if (HTTPCode == 422) {
		errorCode = OCTClientErrorServiceRequestFailed;
		
		NSArray *errors = [responseDictionary[@"errors"] mtl_mapUsingBlock:^(NSDictionary *errorDictionary) {
			return [self errorMessageFromErrorDictionary:errorDictionary];
		}];
		NSString *fullMessage = [NSString stringWithFormat:NSLocalizedString(@"%@:\n\n%@", @""), message, [errors componentsJoinedByString:@"\n"]];
		userInfo[NSLocalizedDescriptionKey] = fullMessage;
	} else if (operation.error != nil) {
		errorCode = OCTClientErrorConnectionFailed;
		if ([operation.error.domain isEqual:NSURLErrorDomain]) {
			userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"There was a problem connecting to the server.", @"");
		} else {
			userInfo[NSLocalizedDescriptionKey] = operation.error.userInfo[NSLocalizedDescriptionKey];
		}
	} else {
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"The universe has collapsed.", @"");
	}

	userInfo[OCTClientErrorHTTPStatusCodeKey] = @(HTTPCode);
	if (operation.request.URL != nil) userInfo[OCTClientErrorRequestURLKey] = operation.request.URL;
	if (operation.error != nil) userInfo[NSUnderlyingErrorKey] = operation.error;
	
	return [NSError errorWithDomain:OCTClientErrorDomain code:errorCode userInfo:userInfo];
}

- (void)setUser:(OCTUser *)u {
	if (_user == u) return;
	
	_user = u;
	
	[self setAuthorizationHeaderWithUsername:self.user.login password:self.user.password];
}

@end
