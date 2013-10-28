//
//  OCTClient.h
//  OctoKit
//
//  Created by Josh Abernathy on 3/6/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class OCTGist;
@class OCTGistEdit;
@class OCTNotification;
@class OCTOrganization;
@class OCTRepository;
@class OCTServer;
@class OCTTeam;
@class OCTUser;
@class RACSignal;

// The domain for all errors originating in OCTClient.
extern NSString * const OCTClientErrorDomain;

// A request was made to an endpoint that requires authentication, and the user
// is not logged in.
extern const NSInteger OCTClientErrorAuthenticationFailed;

// The authorization request requires a two-factor authentication one-time
// password.
extern const NSInteger OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired;

// The request was invalid (HTTP error 400).
extern const NSInteger OCTClientErrorBadRequest;

// The server refused to process the request (HTTP error 422).
//
// Among other reasons, this might be sent if one of the
// -requestAuthorizationWithPassword: methods is given an invalid client ID or
// secret.
extern const NSInteger OCTClientErrorServiceRequestFailed;

// There was a problem connecting to the server.
extern const NSInteger OCTClientErrorConnectionFailed;

// JSON parsing failed, or a model object could not be created from the parsed
// JSON.
extern const NSInteger OCTClientErrorJSONParsingFailed;

// The server is too old or new to understand our request.
extern const NSInteger OCTClientErrorUnsupportedServer;

// The GitHub login page could not be opened in a web browser.
//
// This error only affects +signInToServerUsingWebBrowser:scopes:.
extern const NSInteger OCTClientErrorOpeningBrowserFailed;

// A user info key associated with the NSURL of the request that failed.
extern NSString * const OCTClientErrorRequestURLKey;

// A user info key associated with an NSNumber, indicating the HTTP status code
// that was returned with the error.
extern NSString * const OCTClientErrorHTTPStatusCodeKey;

// A user info key associated with an NSNumber-wrapped
// OCTClientOneTimePasswordMedium which indicates the medium of delivery for the
// one-time password required by the API. Only valid when the error's code is
// OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired.
extern NSString * const OCTClientErrorOneTimePasswordMediumKey;

// The scopes for authorization. These can be bitwise OR'd together to request
// multiple scopes.
//
// OCTClientAuthorizationScopesPublicReadOnly   - Public, read-only access.
// OCTClientAuthorizationScopesUserEmail        - Read-only access to the user's
//                                                email.
// OCTClientAuthorizationScopesUserFollow       - Follow/unfollow access.
// OCTClientAuthorizationScopesUser             - Read/write access to profile
//                                                info. This includes OCTClientAuthorizationScopesUserEmail and
//                                                OCTClientAuthorizationScopesUserFollow
// OCTClientAuthorizationScopesRepositoryStatus - Read/write access to public
//                                                and private repository
//                                                commit statuses. This allows
//                                                access to commit statuses
//                                                without access to the
//                                                repository's code.
// OCTClientAuthorizationScopesPublicRepository - Read/write access to public
//                                                repositories and orgs. This
//                                                includes OCTClientAuthorizationScopesRepositoryStatus.
// OCTClientAuthorizationScopesRepository       - Read/write access to public
//                                                and private repositories and
//                                                orgs. This includes OCTClientAuthorizationScopesRepositoryStatus.
// OCTClientAuthorizationScopesRepositoryDelete - Delete access to adminable
//                                                repositories.
// OCTClientAuthorizationScopesNotifications    - Read access to the user's
//                                                notifications.
// OCTClientAuthorizationScopesGist             - Write access to the user's
//                                                gists.
typedef enum : NSUInteger {
	OCTClientAuthorizationScopesPublicReadOnly = 1 << 0,

	OCTClientAuthorizationScopesUserEmail = 1 << 1,
	OCTClientAuthorizationScopesUserFollow = 1 << 2,
	OCTClientAuthorizationScopesUser = 1 << 3,

	OCTClientAuthorizationScopesRepositoryStatus = 1 << 4,
	OCTClientAuthorizationScopesPublicRepository = 1 << 5,
	OCTClientAuthorizationScopesRepository = 1 << 6,
	OCTClientAuthorizationScopesRepositoryDelete = 1 << 7,

	OCTClientAuthorizationScopesNotifications = 1 << 8,

	OCTClientAuthorizationScopesGist = 1 << 9,
} OCTClientAuthorizationScopes;

// The medium used to deliver the one-time password.
//
// OCTClientOneTimePasswordMediumSMS - Delivered via SMS.
// OCTClientOneTimePasswordMediumApp - Delivered via an app.
typedef enum : NSUInteger {
	OCTClientOneTimePasswordMediumSMS,
	OCTClientOneTimePasswordMediumApp,
} OCTClientOneTimePasswordMedium;

// Represents a single GitHub session.
//
// **NOTE:** You must invoke +setUserAgent: before making any requests using
// OCTClient, and +setClientID:clientSecret: before attempting to authenticate.
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
// authenticated with the server — only whether it will attempt to.
//
// This will be NO when `token` is `nil`.
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;

// The OAuth access token that the client was initialized with.
//
// You should protect this token like a password. **Never** save it to disk in
// plaintext — use the keychain instead.
//
// This will be `nil` when the client is created using
// +unauthenticatedClientWithUser:.
@property (nonatomic, copy, readonly) NSString *token;

// Sets the HTTP User-Agent for the current app.
//
// This method is thread-safe, and _must_ be invoked before making any requests.
// This will have no effect on any clients that have already been created.
//
// userAgent - The user agent to set. This must not be nil.
+ (void)setUserAgent:(NSString *)userAgent;

// Sets OAuth client information for the current app.
//
// If you only ever use +unauthenticatedClientWithUser:, you do not need to use this
// method. Otherwise, you must invoke this method before making any
// authentication requests.
//
// The information you provide here must match a registered OAuth application on
// the server. You can create a new OAuth application via
// https://github.com/settings/applications/new.
//
// Note that, because the `clientSecret` will be embedded in your app and sent
// over the user's internet connection, the secret isn't terribly secret. To
// help mitigate the risk of a web app stealing and using your `clientID` and
// `clientSecret`, set the Callback URL for your OAuth app to a URL you control.
// Even if this URL is never used by your app, this will prevent other apps
// from using your client ID and secret in a web flow.
//
// This method is thread-safe, and must be invoked before making any
// authentication requests. This will have no effect on any clients that have
// already been created.
//
// clientID     - The OAuth client ID for your application. This must not be
//                nil.
// clientSecret - The OAuth client secret for your application. This must not be
//                nil.
+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

// Initializes the receiver to make requests to the given GitHub server.
// 
// When using this initializer, the `user` property will not be set.
// +authenticatedClientWithUser:token: or +unauthenticatedClientWithUser:
// should typically be used instead.
//
// **NOTE:** You must invoke +setUserAgent: before using this method.
//
// server - The GitHub server to connect to. This argument must not be nil.
//
// This is the designated initializer for this class.
- (id)initWithServer:(OCTServer *)server;

// Creates a client which can access any endpoints that don't require
// authentication.
//
// **NOTE:** You must invoke +setUserAgent: before using this method.
//
// user - The active user. The `user` property of the returned client will be
//        set to this object. This must not be nil.
//
// Returns a new client.
+ (instancetype)unauthenticatedClientWithUser:(OCTUser *)user;

// Creates a client which will authenticate as the given user, using the given
// OAuth token.
//
// This method does not actually perform a login or make a request to the
// server. It only saves authentication information for future requests.
//
// **NOTE:** You must invoke +setUserAgent: before using this method.
//
// user  - The user to authenticate as. The `user` property of the returned
//         client will be set to this object. This must not be nil.
// token - An OAuth token for the given user. This must not be nil.
//
// Returns a new client.
+ (instancetype)authenticatedClientWithUser:(OCTUser *)user token:(NSString *)token;

// Attempts to authenticate as the given user.
//
// Authentication is done using a native OAuth flow. This allows apps to avoid
// presenting a webpage, while minimizing the amount of time the client app
// needs the user's password.
//
// If `user` has two-factor authentication turned on and `oneTimePassword` is
// not provided, the authorization will be rejected with an error whose `code` is
// `OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired`. The behavior
// then depends on the `OCTClientOneTimePasswordMedium` that the user has set:
//
//  * If the user has chosen SMS as their authentication method, they will be
//    sent a one-time password _each time_ this method is invoked.
//  * If the user has chosen to use an app for authentication, they must open
//    their chosen app and use the one-time password it presents.
//
// You can then invoke this method again to request authorization using the
// one-time password entered by the user.
//
// **NOTE:** You must invoke +setUserAgent: and +setClientID:clientSecret:
// before using this method.
//
// user            - The user to authenticate as. The `user` property of the
//                   returned client will be set to this object. This must not be nil.
// password        - The user's password. Cannot be nil.
// oneTimePassword - The one-time password to approve the authorization request.
//                   This may be nil if you have no one-time password to
//                   provide, which will usually be the case unless you've
//                   already requested authorization, `user` has two-factor
//                   authentication on, and the user has entered their one-time
//                   password.
// scopes          - The scopes to request access to. These values can be
//                   bitwise OR'd together to request multiple scopes.
//
// Returns a signal which will send an OCTClient then complete on success, or
// else error.
+ (RACSignal *)signInAsUser:(OCTUser *)user password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes;

// Opens the default web browser to the given GitHub server, and prompts the
// user to sign in.
//
// Your app must be the preferred application for handling its URL callback, as set
// in your OAuth Application Settings). When the callback URL is opened using
// your app, you must invoke +completeSignInWithCallbackURL: in order for this
// authentication method to complete successfully.
//
// **NOTE:** You must invoke +setUserAgent: and +setClientID:clientSecret:
// before using this method.
//
// server - The server that the user should sign in to. This must not be
//          nil.
// scopes - The scopes to request access to. These values can be
//          bitwise OR'd together to request multiple scopes.
//
// Returns a signal which will send an OCTClient then complete on success, or
// else error. If +completeSignInWithCallbackURL: is never invoked, the returned
// signal will never complete.
+ (RACSignal *)signInToServerUsingWebBrowser:(OCTServer *)server scopes:(OCTClientAuthorizationScopes)scopes;

// Notifies any waiting login processes that authentication has completed.
//
// This only affects authentication started with
// +signInToServerUsingWebBrowser:scopes:. Invoking this method will allow
// the originating login process to continue. If `callbackURL` does not
// correspond to any in-progress logins, nothing will happen.
//
// callbackURL - The URL that the app was opened with. This must not be nil.
+ (void)completeSignInWithCallbackURL:(NSURL *)callbackURL;

@end

@interface OCTClient (Requests)

// Creates a mutable URL request, which when sent will conditionally fetch the
// latest data from the server. If the latest data matches `etag`, nothing is
// downloaded and the call does not count toward the API rate limit.
//
// method          - The HTTP method to use in the request
//                   (e.g., "GET" or "POST").
// path            - The path to request, relative to the base API endpoint.
//                   This path should _not_ begin with a forward slash.
// parameters      - HTTP parameters to encode and send with the request.
// notMatchingEtag - An ETag to compare the server data against, previously
//                   retrieved from an instance of OCTResponse. If the content
//                   has not changed since, no new data will be fetched when
//                   this request is sent. This argument may be nil to always
//                   fetch the latest data.
//
// Returns an NSMutableURLRequest that you can enqueue using
// -enqueueRequest:resultClass:.
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag;

// Enqueues a request to be sent to the server.
//
// This will automatically fetch all pages of the given endpoint. Each object
// from each page will be sent independently on the returned signal, so
// subscribers don't have to know or care about this pagination behavior.
//
// request       - The previously constructed URL request for the endpoint.
// resultClass   - A subclass of OCTObject that the response data should be
//                 returned as, and will be accessible from the parsedResult
//                 property on each OCTResponse. If this is nil, NSDictionary
//                 will be used for each object in the JSON received.
//
// Returns a signal which will send an instance of `OCTResponse` for each parsed
// JSON object, then complete. If an error occurs at any point, the returned
// signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass;

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

// Fetches the starred repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserStarredRepositories;

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
// Returns a signal which will send zero or more OCTResponses (of OCTEvents) if
// new data was downloaded. Unrecognized events will be omitted from the result.
// On success, the signal will send completed regardless of whether there was
// new data. If no `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserEventsNotMatchingEtag:(NSString *)etag;

@end

@interface OCTClient (Notifications)

// Conditionally fetch unread notifications for the user. If the latest data
// matches `etag`, the call does not count toward the API rate limit.
//
// etag        - An Etag from a previous request, used to avoid downloading
//               unnecessary data.
// includeRead - Whether to include notifications that have already been read.
// since       - If not nil, only notifications updated after this date will be
//               included.
//
// Returns a signal which will zero or more OCTResponses (of OCTNotifications)
// if new data was downloaded. On success, the signal will send completed
// regardless of whether there was new data. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)fetchNotificationsNotMatchingEtag:(NSString *)etag includeReadNotifications:(BOOL)includeRead updatedSince:(NSDate *)since;

// Mark a notification thread as having been read.
//
// threadURL - The API URL of the thread to mark as read. Cannot be nil.
//
// Returns a signal which will send completed on success. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)markNotificationThreadAsReadAtURL:(NSURL *)threadURL;

// Mutes all further notifications from a thread.
//
// threadURL - The API URL of the thread to mute. Cannot be nil.
//
// Returns a signal which will send completed on success. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)muteNotificationThreadAtURL:(NSURL *)threadURL;

@end

@interface OCTClient (Repository)

// Fetches the content at `relativePath` at the given `reference` from the
// `repository`.
//
// In case `relativePath` is `nil` the contents of the repository root will be
// sent.
//
// repository   - The repository from which the file should be fetched.
// relativePath - The relative path (from the repository root) of the file that
//                should be fetched, may be `nil`.
// reference    - The name of the commit, branch or tag, may be `nil` in which
//                case it defaults to the default repo branch.
//
// Returns a signal which will send zero or more OCTContents depending on if the
// relative path resolves at all or, resolves to a file or directory.
- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference;

// Fetches the readme of a `repository`.
//
// repository - The repository for which the readme should be fetched.
//
// Returns a signal which will send zero or one OCTContent.
- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository;

// Fetches a specific repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTRepository.
- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner;

// Fetches the tree for the given reference.
//
// reference -  The SHA, branch, reference, or tag to fetch. May be nil, in
//              which case HEAD is fetched.
// repository - The repository from which the tree should be fetched. Cannot be
//              nil.
// recursive  - Should the tree be fetched recursively?
//
// Returns a signal which will send an OCTTree and complete or error.
- (RACSignal *)fetchTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository recursive:(BOOL)recursive;

@end

@interface OCTClient (Gist)

// Fetches all the gists for the current user.
//
// Returns a signal which will send zero or more OCTGists and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)fetchGists;

// Edits one or more files within a gist.
//
// edit - The changes to make to the gist. This must not be nil.
// gist - The gist to modify. This must not be nil.
//
// Returns a signal which will send the updated OCTGist and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)applyEdit:(OCTGistEdit *)edit toGist:(OCTGist *)gist;

// Creates a gist using the given changes.
//
// edit - The changes to use for creating the gist. This must not be nil.
//
// Returns a signal which will send the created OCTGist and complete. If the client
// is not `authenticated`, the signal will error immediately.
- (RACSignal *)createGistWithEdit:(OCTGistEdit *)edit;

@end
