# Building the prototype

## Current repository state

The repository contains a Swift Package for the reusable core and a SwiftUI app entry file under `iOSApp/`. The SwiftUI file is source for an iOS application target; it is not yet an Xcode project by itself.

## Requirements

- macOS with Xcode installed to build and run the iOS app.
- iOS 16 or later for the current Swift Package platform declaration.
- A simulator or test device for UI validation.

## Validate the core

From the repository root on macOS with Swift installed:

```sh
swift test
```

The tests cover valid package metadata, rejected traversal-style identifiers, unsupported permissions, JSON decoding, and managed package data paths.

## Create the iOS app target

1. In Xcode, create an iOS App project named `LaraJailed` using SwiftUI.
2. Add `iOSApp/LaraJailedApp.swift` to the app target.
3. Add the repository's local Swift package as a local package dependency and select `LaraJailedCore`.
4. Ensure the app target deployment target is iOS 16 or later.
5. Build and run on a simulator before testing on a device.

Do not add any third-party Nyxian binaries or entitlements at this stage. The shell prototype is UI only and does not install a bootstrap or modify system processes.
