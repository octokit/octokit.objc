# OctoKit

OctoKit is a Cocoa and Cocoa Touch framework for interacting with the [GitHub
API](http://developer.github.com), built using
[AFNetworking](https://github.com/AFNetworking/AFNetworking),
[Mantle](https://github.com/MantleFramework/Mantle), and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).


## <a name='TOC'>Table of Contents</a>

- [Making requests](#makingRequests)
    - [Receiving all results at once](#receivingOne)
    - [Receiving all results at once](#receivingOne)
    - [Receiving results on the main thread](#receivingAll)
    - [Cancelling a request](#cancel)
- [Authentication](#authentication)
    - [Signing in through a browser](#browser)
    - [Signing in through the app](#app)
    - [Choosing an authentication method dynamically](#auto)
    - [Saving credentials](#saveCred)
- [Importing OctoKit](#import)
    - [CocoaPods](#cocoapod)
    - [Manual](#manual)
    - [Copying the frameworks (osX only)](#copy)
- [Contributing](https://github.com/octokit/octokit.objc/blob/master/CONTRIBUTING.md)
    - [Code Convention](https://github.com/github/objective-c-conventions) 
- [License](#license)

## <a name='makingRequests'>Making Requests<a>

In order to begin interacting with the API, you must instantiate an
[OCTClient](OctoKit/OCTClient.h). There are two ways to create a client without
[authenticating](#authentication):

 1. `-initWithServer:` is the most basic way to initialize a client. It accepts
    an [OCTServer](OctoKit/OCTServer.h), which determines whether to connect to
    GitHub.com or a [GitHub Enterprise](https://enterprise.github.com) instance.
 1. `+unauthenticatedClientWithUser:` is similar, but lets you set an _active
    user_, which is required for certain requests.

We'll focus on the second method, since we can do more with it. Let's create
a client that connects to GitHub.com:

```objc
OCTUser *user = [OCTUser userWithRawLogin:username server:OCTServer.dotComServer];
OCTClient *client = [OCTClient unauthenticatedClientWithUser:user];
```

After we've got a client, we can start fetching data. Each request method on
`OCTClient` returns
a [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) signal, which
is kinda like a [future or
promise](http://en.wikipedia.org/wiki/Futures_and_promises):

```objc
// Prepares a request that will load all of the user's repositories, represented
// by `OCTRepository` objects.
//
// Note that the request is not actually _sent_ until you use one of the
// -subscribe… methods below.
RACSignal *request = [client fetchUserRepositories];
```

However, you don't need a deep understanding of RAC to use OctoKit. There are
just a few basic operations to be aware of.

    
### <a name='receivingOne'>Receiving all results at once</a>

It often makes sense to handle each result object independently, so you can
spread any processing out instead of doing it all at once:

```objc
// This method actually kicks off the request, handling any results using the
// blocks below.
[request subscribeNext:^(OCTRepository *repository) {
    // This block is invoked for _each_ result received, so you can deal with
    // them one-by-one as they arrive.
} error:^(NSError *error) {
    // Invoked when an error occurs.
    //
    // Your `next` and `completed` blocks won't be invoked after this point.
} completed:^{
    // Invoked when the request completes and we've received/processed all the
    // results.
    //
    // Your `next` and `error` blocks won't be invoked after this point.
}];
```

### <a name='receivingOne'>Receiving all results at once</a>

If you can't do anything until you have _all_ of the results, you can "collect"
them into a single array:

```objc
[[request collect] subscribeNext:^(NSArray *repositories) {
    // Thanks to -collect, this block is invoked after the request completes,
    // with _all_ the results that were received.
} error:^(NSError *error) {
    // Invoked when an error occurs. You won't receive any results if this
    // happens.
}];
```

    
### <a name='receivingAll'>Receiving results on the main thread</a>

The blocks in the above examples will be invoked in the background, to avoid
slowing down the main thread. However, if you want to run UI code, you shouldn't
do it in the background, so you must "deliver" results to the main thread
instead:

```objc
[[request deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(OCTRepository *repository) {
    // ...
} error:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                    message:@"Something went wrong."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
} completed:^{
    [self.tableView reloadData];
}];
```

### <a name='cancel'>Cancelling a request</a>

All of the `-subscribe…` methods actually return
a [RACDisposable](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoaFramework/ReactiveCocoa/RACDisposable.h)
object. Most of the time, you don't need it, but you can hold onto it if you
want to cancel requests:

```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    RACDisposable *disposable = [[[[self.client
        fetchUserRepositories]
        collect]
        deliverOn:RACScheduler.mainThreadScheduler]
        subscribeNext:^(NSArray *repositories) {
            [self addTableViewRowsForRepositories:repositories];
        } error:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                            message:@"Something went wrong."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert show];
        }];

    // Save the disposable into a `strong` property, so we can access it later.
    self.repositoriesDisposable = disposable;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Cancels the request for repositories if it's still in progress. If the
    // request already terminated, nothing happens.
    [self.repositoriesDisposable dispose];
}
```

## <a name='authentication'>Authentication</a>

OctoKit supports two variants of [OAuth2](http://developer.github.com/v3/oauth/)
for signing in. We recommend the [browser-based
approach](#signing-in-through-a-browser), but you can also implement a [native
sign-in flow](#signing-in-through-the-app) if desired.

In both cases, you will need to [register your OAuth
application](https://github.com/settings/applications/new), and provide OctoKit
with your client ID and client secret before trying to authenticate:

```objc
[OCTClient setClientID:@"abc123" clientSecret:@"654321abcdef"];
```

### <a name='browser'>Signing in through a browser</a>

With this API, the user will be redirected to their default browser (on OS X) or
Safari (on iOS) to sign in, and then redirected back to your app. This is the
easiest approach to implement, and means the user never has to enter their
password directly into your app — plus, they may even be signed in through the
browser already!

To get started, you must [implement a custom URL
scheme](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html#//apple_ref/doc/uid/TP40007072-CH7-SW50)
for your app, then use something matching that scheme for your [OAuth
application's](https://github.com/settings/applications) callback URL. The
actual URL doesn't matter to OctoKit, so you can use whatever you'd like, just
as long as the URL scheme is correct.

Whenever your app is opened from your URL, or asked to open it, you must pass it
directly into `OCTClient`:

*iOs*
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // For handling a callback URL like my-app://oauth
    if ([URL.host isEqual:@"oauth"]) {
        [OCTClient completeSignInWithCallbackURL:URL];
        return YES;
    } else {
        return NO;
    }
}
```

*osX*
```objc
// Register the callback 
NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];

# Event handler when the web page 
- (bool)handleGetURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL* url = [NSURL URLWithString:urlString];
    if ([url.host isEqual:@"oauth"]) {
        [OCTClient completeSignInWithCallbackURL:url];
        return YES;
    } else {
        return NO;
    }
}

```


After that's set up properly, you can present the sign in page at any point. The
pattern is very similar to [making a request](#making-requests), except that you
receive an `OCTClient` instance as a reply:

```objc
[[OCTClient
    signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesUser]
    subscribeNext:^(OCTClient *authenticatedClient) {
        // Authentication was successful. Do something with the created client.
    } error:^(NSError *error) {
        // Authentication failed.
    }];
```

You can also choose to [receive the client on the main
thread](#receiving-results-on-the-main-thread), just like with any other request.


### <a name='app'>Signing in through the app</a>

If you don't want to open a web page, you can use the native authentication flow
and implement your own sign-in UI. However, [two-factor
authentication](https://help.github.com/articles/about-two-factor-authentication)
makes this process somewhat complex, and the native authentication flow may not work
with [GitHub Enterprise](https://enterprise.github.com) instances that use [single
sign-on](http://en.wikipedia.org/wiki/Single_sign-on).

Whenever the user wants to sign in, present your custom UI. After the form has
been filled in with a username and password (and perhaps a server URL, for GitHub
Enterprise users), you can attempt to authenticate. The pattern is very similar to
[making a request](#making-requests), except that you receive an `OCTClient` instance
as a reply:

```objc
OCTUser *user = [OCTUser userWithRawLogin:username server:OCTServer.dotComServer];
[[OCTClient
    signInAsUser:user password:password oneTimePassword:nil scopes:OCTClientAuthorizationScopesUser]
    subscribeNext:^(OCTClient *authenticatedClient) {
        // Authentication was successful. Do something with the created client.
    } error:^(NSError *error) {
        // Authentication failed.
    }];
```

_(You can also choose to [receive the client on the main
thread](#receiving-results-on-the-main-thread), just like with any other
request.)_

`oneTimePassword` must be `nil` on your first attempt, since it's impossible to
know ahead of time if a user has two-factor authentication enabled. If they do,
you'll receive an error of code
`OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired`, and should
present a UI for the user to enter the 2FA code they received via SMS or read
from an authenticator app.

Once you have the 2FA code, you can attempt to sign in again. The resulting code
might look something like this:

```objc
- (IBAction)signIn:(id)sender {
    NSString *oneTimePassword;
    if (self.oneTimePasswordVisible) {
        oneTimePassword = self.oneTimePasswordField.text;
    } else {
        oneTimePassword = nil;
    }

    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    [[[OCTClient
        signInAsUser:username password:password oneTimePassword:oneTimePassword scopes:OCTClientAuthorizationScopesUser]
        deliverOn:RACScheduler.mainThreadScheduler]
        subscribeNext:^(OCTClient *client) {
            [self successfullyAuthenticatedWithClient:client];
        } error:^(NSError *error) {
            if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
                // Show OTP field and have the user try again.
                [self showOneTimePasswordField];
            } else {
                // The error isn't a 2FA prompt, so present it to the user.
                [self presentError:error];
            }
        }];
}
```
 
### <a name='auto'>Choosing an authentication method dynamically</a>

If you really want a [native login flow](#signing-in-through-the-app) without
sacrificing the compatibility of [browser-based
login](#signing-in-through-a-browser), you can inspect a server's metadata
to determine how to authenticate.

However, because not all GitHub Enterprise servers support this API, you should
handle any errors returned:

```objc
[[OCTClient
    fetchMetadataForServer:someServer]
    subscribeNext:^(OCTServerMetadata *metadata) {
        if (metadata.supportsPasswordAuthentication) {
            // Authenticate with +signInAsUser:password:oneTimePassword:scopes:
        } else {
            // Authenticate with +signInToServerUsingWebBrowser:scopes:
        }
    } error:^(NSError *error) {
        if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorUnsupportedServer) {
            // The server doesn't support capability checks, so fall back to one
            // method or the other.
        }
    }];
```


### <a name='saveCred'>Saving credentials</a>

Generally, you'll want to save an authenticated OctoKit session, so the user
doesn't have to repeat the sign in process when they open your app again.

Regardless of the authentication method you use, you'll end up with an
`OCTClient` instance after the user signs in successfully. An authenticated
client has `user` and `token` properties. To remember the user, you need to save
`user.rawLogin` and the OAuth access token into the
[keychain](https://developer.apple.com/library/ios/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html).

When your app is relaunched, and you want to use the saved credentials, skip the
normal sign-in methods and create an authenticated client directly:

```objc
OCTUser *user = [OCTUser userWithRawLogin:savedLogin server:OCTServer.dotComServer];
OCTClient *client = [OCTClient authenticatedClientWithUser:user token:savedToken];
```

If the credentials are still valid, you can make authenticated requests
immediately. If not valid (perhaps because the OAuth token was revoked by the
user), you'll receive an error after sending your first request, and can ask the
user to sign in again.

## <a name='import'>Importing OctoKit</a>

OctoKit is still new and moving fast, so we may make breaking changes from
time-to-time, but it has partial unit test coverage and is already being used
in [GitHub for Mac](http://mac.github.com)'s production code.


### <a name='cocoapod'>CocoaPods</a>

[CocoaPods](http://cocoapods.org) is a great tool to manage external dependancy in objc projects.
There are some [OctoKit podspecs](https://github.com/CocoaPods/Specs/tree/master/OctoKit)
that have been generously contributed by third parties.


### <a name='manual'>Manual</a>


 1. Add the OctoKit repository as a submodule of your application's
    repository.
 1. Run `script/bootstrap` from within the OctoKit folder.
 1. Drag and drop `OctoKit.xcodeproj`, `OctoKitDependencies.xcodeproj`,
    `ReactiveCocoa.xcodeproj`, and `Mantle.xcodeproj` into the top-level of your
    application's project file or workspace. The latter three projects can be
    found within the `External` folder.
 1. On the "Build Phases" tab of your application target, add OctoKit,
    ReactiveCocoa, and Mantle to the "Link Binary With Libraries" phase.
    * **On iOS**, add the `.a` libraries.
    * **On OS X**, add the `.framework` bundles. All of the frames must also be
      added to any ["Copy Frameworks"](#copying-the-frameworks) build phase.
 1. Add `$(BUILD_ROOT)/../IntermediateBuildFilesPath/UninstalledProducts/include
    $(inherited)` to the "Header Search Paths" build setting (this is only
    necessary for archive builds, but it has no negative effect otherwise).
 1. **For iOS targets**, add `-ObjC` to the "Other Linker Flags" build setting.


### <a name='copy'>Copying the frameworks (osX only)<a/>

_This is only needed **on OS X**._

 1. Go to the "Build Phases" tab of your application target.
 1. If you don't already have one, add a "Copy Files" build phase and target
    the "Frameworks" destination.
 1. Drag `OctoKit.framework` from the OctoKit project’s `Products` Xcode group
    into the "Copy Files" build phase you just created (or the one that you
    already had).
 1. A reference to the framework will now appear at the top of your
    application’s Xcode group, select it and show the "File Inspector".
 1. Change the "Location" to "Relative to Build Products".
 1. Now do the same (starting at step 2) for the frameworks within the External
    folder.


## <a name='license'>License</a>

OctoKit is released under the MIT license. See
[LICENSE.md](https://github.com/Octokit/octokit.objc/blob/master/LICENSE.md).
