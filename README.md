# OctoKit

OctoKit is a Cocoa and Cocoa Touch framework for interacting with the [GitHub
API](http://developer.github.com), built using
[AFNetworking](https://github.com/AFNetworking/AFNetworking),
[Mantle](https://github.com/github/Mantle), and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

## Getting Started

OctoKit is still new and moving fast, so we may make breaking changes from
time-to-time, but it has partial unit test coverage and is already being used
in [GitHub for Mac](http://mac.github.com)'s production code.

To add OctoKit to your application:

 1. Add the OctoKit repository as a submodule of your application's
    repository.
 1. Run `script/bootstrap` from within the OctoKit folder.
 1. Drag and drop `OctoKit.xcodeproj` into the top-level of your application's workspace (or into the top-level of your project file to create a new workspace).
 1. Drag and drop `ReactiveCocoa.xcodeproj` into the top level of your workspace. (This project can be found in the `External` folder).
 1. Drag and drop `Mantle.xcodeproj` into the top level of your workspace. (This project can be found in the `External` folder).
 1. On the "Build Phases" tab of your application target, add OctoKit to the
    "Link Binary With Libraries" phase.
    * **On iOS**, add `libOctoKit.a`.
    * **On OS X**, add `OctoKit.framework`. The framework as well as its
      subframeworks (`ReactiveCocoa.framework` and `Mantle.framework`) must also
      be added to any ["Copy Frameworks"](#copying-the-frameworks) build phase.
 1. Add `$(BUILD_ROOT)/../IntermediateBuildFilesPath/UninstalledProducts/include
    $(inherited)` to the "Header Search Paths" build setting (this is only
    necessary for archive builds, but it has no negative effect otherwise).
 1. **For iOS targets**, add `-ObjC` to the "Other Linker Flags" build setting.

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
 1. Now do the same (starting at step 2) for the ReactiveCocoa and Mantle frameworks.


## License

OctoKit is released under the MIT license. See
[LICENSE.md](https://github.com/Octokit/octokit.objc/blob/master/LICENSE.md).
