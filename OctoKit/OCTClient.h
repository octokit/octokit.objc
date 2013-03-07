//
//  OCTClient.h
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "AFNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@class OCTOrganization;
@class OCTServer;
@class OCTTeam;
@class OCTUser;

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

// The active user for this session.
//
// This may be set regardless of whether the session is authenticated or
// unauthenticated, and will control which username is used for endpoints
// that require one. For example, this user's login will be used with
// -fetchUserEventsNotMatchingEtag:.
@property (nonatomic, strong, readonly) OCTUser *user;

// Whether this client supports authenticated endpoints.
//
// Note that this property does not specify whether the client has successfully
// authenticated with the server – only whether it will attempt to.
//
// This will only be YES when created with
// +authenticatedClientWithUser:password:.
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;

// Initializes the receiver to make requests to the given GitHub server.
// 
// When using this initializer, the `user` property will not be set.
// +authenticatedClientWithUser:password: or +unauthenticatedClientWithUser:
// should typically be used instead.
//
// server - The GitHub server to connect to. This argument must not be nil.
//
// This is the designated initializer for this class.
- (id)initWithServer:(OCTServer *)server;

// Creates a client which will attempt to authenticate as the given user, using
// the given password.
//
// Note that this method does not actually perform a login or make a request to
// the server – it only sets an authorization header for future requests.
//
// user     - The user to authenticate as. The `user` property of the returned
//            client will be set to this object. This argument must not be nil.
// password - The password for the given user.
//
// Returns a new client.
+ (instancetype)authenticatedClientWithUser:(OCTUser *)user password:(NSString *)password;

// Creates a client which can access any endpoints that don't require
// authentication.
//
// user - The active user. The `user` property of the returned client will be
//        set to this object. This argument must not be nil.
//
// Returns a new client.
+ (instancetype)unauthenticatedClientWithUser:(OCTUser *)user;

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
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters cachePolicy:(NSURLRequestCachePolicy)cachePolicy resultClass:(Class)resultClass;

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
- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag cachePolicy:(NSURLRequestCachePolicy)cachePolicy resultClass:(Class)resultClass;

- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag resultClass:(Class)resultClass;

@end

@interface OCTClient (User)

// Fetches the full information of the current `user`.
//
// Returns a signal which sends a new OCTUser. The user may contain different
// levels of information depending on whether the client is `authenticated` or
// not. If no `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserInfo;

// Fetches the repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserRepositories;

// Creates a repository under the user's account.
//
// Returns a signal which sends the new OCTRepository. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate;

@end

@interface OCTClient (Organizations)

// Fetches the organizations that the current user is a member of.
//
// Returns a signal which sends zero or more OCTOrganization objects. Private
// organizations will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserOrganizations;

// Fetches the specified organization's full information.
//
// Returns a signal which sends a new OCTOrganization.
- (RACSignal *)fetchOrganizationInfo:(OCTOrganization *)organization;

// Fetches the specified organization's repositories.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated` and the
// `user` has permission to see them.
- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization;

// Creates a repository under the specified organization's account, and
// associates it with the given team.
//
// Returns a signal which sends the new OCTRepository. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate;

// Fetches the specified organization's teams.
//
// Returns a signal which sends zero or more OCTTeam objects. If the client is
// not `authenticated`, the signal will error immediately.
- (RACSignal *)fetchTeamsForOrganization:(OCTOrganization *)organization;

@end

@interface OCTClient (Keys)

// Fetches the public keys for the current `user`.
//
// Returns a signal which sends zero or more OCTPublicKey objects. Unverified
// keys will only be included if the client is `authenticated`. If no `user` is
// set, the signal will error immediately.
- (RACSignal *)fetchPublicKeys;

// Adds a new public key to the current user's profile.
//
// Returns a signal which sends the new OCTPublicKey. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title;

@end

@interface OCTClient (Events)

// Conditionally fetches events from the current user's activity stream. If
// the latest data matches `etag`, the call does not count toward the API rate
// limit.
//
// Returns a signal which will send zero or more OCTEvents if new data was
// downloaded. Unrecognized events will be omitted from the result. On success,
// the signal will send completed regardless of whether there was new data. If
// no `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag;

@end
