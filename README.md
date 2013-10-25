# OctoKit

OctoKit is a Cocoa and Cocoa Touch framework for interacting with the [GitHub
API](http://developer.github.com), built using
[AFNetworking](https://github.com/AFNetworking/AFNetworking),
[Mantle](https://github.com/github/Mantle), and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

## Making Requests

Before any requests can be made, you must set the user agent for your app, as
[required by the API](http://developer.github.com/v3/#user-agent-required):

```objc
OCTClient.userAgent = @"OctoKit-README-Examples/1.0";
```

After that's done, you must instantiate an `OCTClient` to begin interacting with
the API. There are two ways to create a client that doesn't require
[authentication](#authentication):

 1. `-initWithServer:` is the most basic way to initialize a client. It accepts
    an `OCTServer`, which determines whether to connect to GitHub.com or
    a [GitHub Enterprise](https://enterprise.github.com) instance.
 1. `+unauthenticatedClientWithUser:` is similar, but lets you set an _active
    user_, used by some requests (e.g., `-fetchUserRepositories`).

We'll focus on the second method, since we can do more with it. Let's create
a client that connects to GitHub.com:

```objc
OCTUser *user = [OCTUser userWithLogin:username server:OCTServer.dotComServer];
OCTClient *client = [OCTClient unauthenticatedClientWithUser:user];
```

After we've got a client, we can start fetching data.

Each request method on `OCTClient` returns
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

**To receive results one-by-one:**

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

**To receive all results at once:**

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

**To receive results on the main thread:**

The blocks in the above examples will be invoked in the background, to avoid
slowing down the main thread.

However, if you want to run UI code in those blocks, you shouldn't do it in the
background, so you can "deliver" results to the main thread instead:

```objc
[[request deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(OCTRepository *repository) {
    // ...
} error:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Something went wrong." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
} completed:^{
    [self.tableView reloadData];
}];
```

**To cancel a request:**

All of the `-subscribe…` methods actually return a `RACDisposable` object. Most
of the time, you don't need it, but you can hold onto it if you want to cancel
requests:

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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Something went wrong." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
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

## Authentication

## Importing OctoKit

OctoKit is still new and moving fast, so we may make breaking changes from
time-to-time, but it has partial unit test coverage and is already being used
in [GitHub for Mac](http://mac.github.com)'s production code.

To add OctoKit to your application:

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

If you would prefer to use [CocoaPods](http://cocoapods.org), there are some [OctoKit podspecs](https://github.com/CocoaPods/Specs/tree/master/OctoKit)
that have been generously contributed by third parties.

### Copying the Frameworks

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

## License

OctoKit is released under the MIT license. See
[LICENSE.md](https://github.com/Octokit/octokit.objc/blob/master/LICENSE.md).
