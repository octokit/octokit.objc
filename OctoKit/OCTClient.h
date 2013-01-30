//
//  OCTClient.h
//  OctoClient
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "AFNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@class OCTUser;
@class OCTOrg;
@class OCTTeam;

extern NSString * const OCTClientErrorDomain;
extern const NSInteger OCTClientErrorAuthenticationFailed;
extern const NSInteger OCTClientErrorBadRequest;
extern const NSInteger OCTClientErrorServiceRequestFailed;
extern const NSInteger OCTClientErrorConnectionFailed;
extern const NSInteger OCTClientErrorJSONParsingFailed;

extern NSString * const OCTClientErrorRequestURLKey; // NSURL
extern NSString * const OCTClientErrorHTTPStatusCodeKey; // NSNumber wrapping an NSInteger


@interface OCTClient : AFHTTPClient

@property (nonatomic, readonly, strong) OCTUser *user;

+ (OCTClient *)clientForUser:(OCTUser *)user;

// Enqueues a request that always fetches the latest data from the server.
//
// Returns a subscribable which, upon success, will send an instance of
// `resultClass` (or an array thereof, for multi-page responses), then send
// completed.
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass;

// Enqueues a request which will conditionally fetch the latest data from the
// server. If the latest data matches `etag`, nothing is downloaded and the call
// does not count toward the API rate limit.
//
// Returns a subscribable which, upon success, will send an instance of
// OCTResponse _if new data was retrieved_. On success, the subscribable
// will send completed regardless of whether there was new data.
- (RACSignal *)enqueueConditionalRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag resultClass:(Class)resultClass;

//
// User
//
- (RACSignal *)login;
- (RACSignal *)fetchUserInfo;

- (RACSignal *)fetchUserRepos;
- (RACSignal *)createRepoWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate;

//
// Orgs
//
- (RACSignal *)fetchUserOrgs;
- (RACSignal *)fetchOrgInfo:(OCTOrg *)org;

- (RACSignal *)fetchReposForOrg:(OCTOrg *)org;
- (RACSignal *)createRepoWithName:(NSString *)name org:(OCTOrg *)org team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate;

- (RACSignal *)fetchTeamsForOrg:(OCTOrg *)org;

// 
// Public Keys
// 
- (RACSignal *)fetchPublicKeys;
- (RACSignal *)postPublicKey:(NSString *)key title:(NSString *)title;

//
// Events
//

// Conditionally fetches events from the logged-in user's activity stream. If
// the latest data matches `etag`, the call does not count toward the API rate
// limit.
//
// Returns a subscribable which will send an array of OCTEvents if data was
// downloaded. Unrecognized events will be omitted from the result.
- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag;

@end
