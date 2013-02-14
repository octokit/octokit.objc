//
//  OCTClient.h
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "AFNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@class OCTUser;
@class OCTOrganization;
@class OCTTeam;

// The domain for all errors originating in OCTClient.
extern NSString * const OCTClientErrorDomain;

// A request was made to an endpoint that requires authentication, and the user
// is not logged in.
extern const NSInteger OCTClientErrorAuthenticationFailed;

// The request was invalid (HTTP error 400).
extern const NSInteger OCTClientErrorBadRequest;

// The server refused to process the request (HTTP error 422).
extern const NSInteger OCTClientErrorServiceRequestFailed;

// There was a problem connecting to the server.
extern const NSInteger OCTClientErrorConnectionFailed;

// JSON parsing failed, or a model object could not be created from the parsed
// JSON.
extern const NSInteger OCTClientErrorJSONParsingFailed;

// A user info key associated with the NSURL of the request that failed.
extern NSString * const OCTClientErrorRequestURLKey;

// A user info key associated with an NSNumber, indicating the HTTP status code
// that was returned with the error.
extern NSString * const OCTClientErrorHTTPStatusCodeKey;

// Represents a single GitHub session.
//
// Most of the methods on this class return a RACSignal representing a request
// made to the API. The returned signal will deliver its results on a background
// RACScheduler.
//
// To avoid hitting the network for a result that won't be used, **no request
// will be sent until the returned signal is subscribed to.** To cancel an
// in-flight request, simply dispose of all subscriptions.
//
// For more information about the behavior of requests, see
// -enqueueRequestWithMethod:path:parameters:resultClass: and
// -enqueueConditionalRequestWithMethod:path:parameters:notMatchingEtag:resultClass:,
// upon which all the other request methods are built.
@interface OCTClient : AFHTTPClient

// The user used to authenticate this session.
@property (nonatomic, readonly, strong) OCTUser *user;

// Creates and returns a new OCTClient that authenticates with the given user's
// credentials.
+ (OCTClient *)clientForUser:(OCTUser *)user;

// Enqueues a request that always fetches the latest data from the server.
//
// This will automatically fetch all pages of the given endpoint. Each object
// from each page will be sent independently on the returned signal, so
// subscribers don't have to know or care about this pagination behavior.
//
// To stop fetching pages, simply dispose of all subscriptions to the signal.
//
// method      - The HTTP method to use in the request (e.g., "GET" or "POST").
// path        - The path to request, relative to the base API endpoint. This
//               path should _not_ begin with a forward slash.
// parameters  - HTTP parameters to encode and send with the request.
// resultClass - A subclass of OCTObject that the response data should be
//               returned as. If this is nil, the returned signal will send an
//               NSDictionary for each object in the JSON received.
//
// Returns a signal which will send an instance of `resultClass` for each parsed
// JSON object, then complete. If an error occurs at any point, the returned
// signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass;

// Enqueues a request which will conditionally fetch the latest data from the
// server. If the latest data matches `etag`, nothing is downloaded and the call
// does not count toward the API rate limit.
//
// If the latest data does not match `etag`, this will automatically fetch all
// pages of the given endpoint. Each object from each page will be sent as
// independent OCTResponse objects on the returned signal, so subscribers don't
// have to know or care about this pagination behavior.
//
// To stop fetching pages, simply dispose of all subscriptions to the signal.
//
// method          - The HTTP method to use in the request (e.g., "GET" or
//                   "POST").
// path            - The path to request, relative to the base API endpoint.
//                   This path should _not_ begin with a forward slash.
// parameters      - HTTP parameters to encode and send with the request.
// notMatchingEtag - An ETag to compare the server data against, previously
//                   retrieved from an instance of OCTResponse. If the content
//                   has not changed since, no new data will be fetched. This
//                   argument may be nil to always fetch the latest data.
// resultClass     - A subclass of OCTObject to use for each
//                   OCTResponse.parsedResult. If this is nil, the
//                   `parsedResult` will be an NSDictionary.
//
// Returns a signal which will send an instance of OCTResponse for each JSON
// object _if new data was retrieved_. On success, the signal will send
// completed regardless of whether there was new data. If an error occurs at any
// point, the returned signal will send it immediately, then terminate.
- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag resultClass:(Class)resultClass;

@end

@interface OCTClient (User)

// Logs the user in.
//
// Returns a signal which sends a new OCTUser.
- (RACSignal *)login;

// Fetches the current user's full information.
//
// Returns a signal which sends a new OCTUser.
- (RACSignal *)fetchUserInfo;

// Fetches the current user's repositories.
//
// Returns a signal which sends zero or more OCTRepository objects.
- (RACSignal *)fetchUserRepositories;

// Creates a repository under the user's account.
//
// Returns a signal which sends the new OCTRepository.
- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate;

@end

@interface OCTClient (Organizations)

// Fetches the organizations that the current user is a member of.
//
// Returns a signal which sends zero or more OCTOrganization objects.
- (RACSignal *)fetchUserOrganizations;

// Fetches the specified organization's full information.
//
// Returns a signal which sends a new OCTOrganization.
- (RACSignal *)fetchOrganizationInfo:(OCTOrganization *)organization;

// Fetches the specified organization's repositories.
//
// Returns a signal which sends zero or more OCTRepository objects.
- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization;

// Creates a repository under the specified organization's account, and
// associates it with the given team.
//
// Returns a signal which sends the new OCTRepository.
- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate;

// Fetches the specified organization's teams.
//
// Returns a signal which sends zero or more OCTTeam objects.
- (RACSignal *)fetchTeamsForOrganization:(OCTOrganization *)organization;

@end

@interface OCTClient (Keys)

// Fetches the current user's public keys.
//
// Returns a signal which sends zero or more OCTPublicKey objects.
- (RACSignal *)fetchPublicKeys;

// Adds a new public key to the current user's profile.
//
// Returns a signal which sends the new OCTPublicKey.
- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title;

@end

@interface OCTClient (Events)

// Conditionally fetches events from the logged-in user's activity stream. If
// the latest data matches `etag`, the call does not count toward the API rate
// limit.
//
// Returns a signal which will send zero or more OCTEvents if new data was
// downloaded. Unrecognized events will be omitted from the result. On success,
// the signal will send completed regardless of whether there was new data.
- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag;

@end
