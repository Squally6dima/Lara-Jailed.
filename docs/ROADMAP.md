# Roadmap

## Phase 0 — Repository and feasibility
- [x] Confirm repository and default branch.
- [ ] Record source/license provenance for Procursus Jailed and Nyxian reference materials.
- [ ] Choose the app target and minimum supported iOS version.
- [ ] Confirm which features can be implemented using public APIs.

## Phase 1 — Shell prototype
- [ ] App entry, navigation, home screen, settings.
- [ ] iOS 18-inspired design tokens and reusable components.
- [ ] Mock app launcher and extension catalog.
- [ ] Accessibility and dynamic type checks.

## Phase 2 — Runtime and packages
- [ ] Runtime abstraction with a mock implementation for tests.
- [ ] Managed prefix and package manifest.
- [ ] Package metadata parser and dependency model.
- [ ] Install/remove transaction preview and rollback plan.
- [ ] Tests for path traversal, duplicate files, and malformed metadata.

## Phase 3 — Extensions
- [ ] Versioned extension manifest.
- [ ] Capability declarations and permission prompts.
- [ ] Sample Lara-Jailed-native extension.
- [ ] Compatibility matrix and developer documentation.

## Non-goals for the first MVP
- Universal support for existing jailbreak tweaks.
- Replacing Apple system apps or protected system components.
- Claiming kernel/root privileges from an ordinary jailed app.
