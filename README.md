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

1. Add the OctoKit repository as a submodule of your application's repository.
1. Run `script/bootstrap` from within the OctoKit folder.
1. Drag and drop `OctoKit.xcodeproj` into your application project (a good place would be the "Frameworks" group).
1. Under "Build Settings" add `$(BUILD_ROOT)/../IntermediateBuildFilesPath/UninstalledProducts/include $(inherited)` to the "Header Search Paths" build setting (this is only necessary for archive builds, but it has no negative effect otherwise).
  * **For iOS targets,** also add `-ObjC` to the "Other Linker Flags" build setting.
  * **For OS X targets,** also add `@loader_path/../Frameworks/OctoKit.framework/Versions/Current/Frameworks $(inherited)` to the "Runpath Search Paths" build setting.
1. Under "Build Phases";
  1. Add OctoKit target as a target dependency for your application target.
     * **For iOS targets,** add `OctoKit iOS` to "Target Dependencies".
     * **For OS X targets,** add `OctoKit Mac` to "Target Dependencies".
  1. Link with OctoKit.
     * **For iOS targets,** add `libOctoKit.a` to "Link Binary With Libraries".
     * **For OS X targets,** add `OctoKit.framework` to "Link Binary With Libraries".
  1. **For OS X targets,** copy `OctoKit.framework` into the application’s `Frameworks` folder. If you don't already have one, add a "Copy Files" build phase and target the "Frameworks" destination. Then add `OctoKit.framework` to it.

## License

OctoKit is released under the MIT license. See
[LICENSE.md](https://github.com/Octokit/octokit.objc/blob/master/LICENSE.md).
