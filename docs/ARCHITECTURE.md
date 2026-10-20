# Lara-Jailed runtime architecture

## Current implementation

- `LaraSystemView` is a SwiftUI shell running inside the Lara app.
- `UserSpaceFileSystem` manages a RootFS directory below the app's Application Support directory.
- `UserSpaceShell` interprets a small allowlisted set of commands directly in Swift. It never launches the host shell.
- Files created by the prototype remain inside the app container.

## Commands currently implemented

`help`, `pwd`, `ls`, `cd`, `cat`, `echo`, `mkdir`, `touch`, `rm`, `clear`, `whoami`, `uname`, `exit`.

This is a small command interpreter, not yet a POSIX shell. Pipes, redirection, environment variables, executable binaries and package scripts are not implemented.

## Procursus Jailed / Nyxian findings

The supplied ROM manifest declares Nyxian-specific T2 entitlements for operations such as process spawning, process enumeration, system task ports, launch-services control and reading/writing outside a normal app container. Its SpringBoard payload is marked as requiring code signing and the ROM states a minimum Nyxian version of 0.11.5.

Those entitlements and ROM install rules are not provided by an ordinary iOS app. The ROM cannot be safely treated as a drop-in bootstrap for Lara until the host API, signing, licensing and device/iOS compatibility are understood. Do not copy protected Apple SpringBoard binaries into the app or claim they can be launched by a normal jailed app.

## Next milestones

1. Test the current Swift package and iOS simulator build in GitHub Actions.
2. Harden path resolution against symlinks and add filesystem UI for opening/editing files.
3. Design a repository index and package install transaction with checksum/signature verification.
4. Evaluate legal/licensing terms and supported integration points for a compatible user-space bootstrap.
5. Implement an app-native process/runtime adapter only where public APIs and the target environment allow it.
