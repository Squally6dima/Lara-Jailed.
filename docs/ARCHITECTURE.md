# Architecture (draft)

## Layers

1. **Shell UI** — iOS 18-inspired visual language, home screen, navigation, settings, and app launcher. Use public frameworks wherever possible.
2. **Runtime service** — a narrowly scoped user-space service for Lara-Jailed-owned processes and files. No assumption of root or kernel privileges.
3. **Bootstrap adapter** — an interface around an optional user-space bootstrap (initially investigate Procursus Jailed). Keep bootstrap-specific behavior behind an adapter.
4. **Package manager** — package metadata, dependency resolution, install/remove plans, integrity checks, and a manifest of files owned by each package. Start with a restricted, testable subset rather than executing arbitrary install scripts.
5. **Extension API** — versioned APIs for extensions built specifically for Lara-Jailed. Extensions run with the permissions available to the host app.
6. **Compatibility layer** — explicit capability checks and per-iOS-version reporting. Existing jailbreak tweaks are not presumed compatible.

## Security boundaries

- The iOS app sandbox remains the default security boundary.
- No claims of arbitrary filesystem access, protected-process injection, or SpringBoard modification without a separately validated mechanism.
- Package installation must reject path traversal and writes outside the managed prefix.
- Do not run package scripts automatically in the first prototype.
- Keep logs free of credentials, cookies, and personal device data.

## Suggested module layout

- LaraJailed/App/ — app entry and lifecycle
- LaraJailed/Shell/ — shell UI and navigation
- LaraJailed/Runtime/ — process and filesystem abstractions
- LaraJailed/Packages/ — package metadata and transaction planning
- LaraJailed/Extensions/ — extension manifest, API version, capability declarations
- LaraJailed/Bootstrap/ — bootstrap adapter interfaces
- Tests/ — unit tests for package validation and path safety
- docs/ — architecture, roadmap, compatibility, and licensing notes

This is a proposed layout, not a claim that these source files already exist.
