# Lara-Jailed.

A research project exploring a user-space, jailed iOS environment with an iOS 18-inspired interface, Unix-style tools, package management, and a documented extension API.

> **Status:** early prototype / architecture stage. This project does not claim to provide a full jailbreak or universal compatibility with existing jailbreak tweaks.

## Goals

- Build a polished iOS-inspired shell and app-launching experience.
- Integrate a user-space bootstrap where iOS sandbox and platform rules permit.
- Explore package installation and removal, starting with a controlled package format and clear ownership of installed files.
- Define a safe, versioned extension API for Lara-Jailed-native extensions.
- Keep the core modular, testable, and independent from any one bootstrap distribution.

## Compatibility expectations

Ordinary jailed apps cannot freely replace Apple system components or inject code into protected processes. Existing tweaks that depend on SpringBoard, private entitlements, kernel access, or jailbreak-specific injection will not work automatically. Compatibility must be evaluated per tweak and per iOS version.

## Initial milestones

1. Document architecture and platform constraints.
2. Inspect the supplied Procursus Jailed ROM and Nyxian package as reference material; do not redistribute third-party contents without checking their licenses.
3. Create the app shell and navigation prototype.
4. Add a user-space command/runtime layer and package-management abstraction.
5. Design and test the Lara-Jailed extension API.
6. Add automated checks, device testing, and compatibility documentation.

## Development principles

- Prefer public APIs and least privilege.
- Never disable Gatekeeper or device security protections as a blanket workaround.
- Keep third-party licenses and attribution intact.
- Treat experimental behavior as experimental and document supported iOS builds explicitly.
