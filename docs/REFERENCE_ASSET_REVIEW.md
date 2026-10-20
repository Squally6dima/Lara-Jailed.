# Reference asset review

Review performed on the user-provided files during initial planning.

## Procursus Jailed ROM archive

The archive contains a ROM/manifest.plist identifying the ROM as **Procursus Jailed**, version 1.0, with a minimum Nyxian version of 0.11.5. It includes a binpack, a bootstrapd executable, and paths/entitlements intended for the Nyxian host environment.

This is not a generic iOS bootstrap that can be copied into an ordinary app. The manifest references Nyxian-specific entitlements and paths, including a SpringBoard path. Those capabilities are host/runtime-dependent and must not be assumed available to Lara-Jailed.

## Nyxian IPA

The supplied IPA identifies the app as org.emexlabs.nyxian, version 0.11.5, with minimum iOS 18.0 and arm64 device capability. It includes a LiveProcess extension and LiveShim framework, along with templates and bundled resources.

This inventory does not establish permission to reuse Nyxian source, private binaries, assets, or proprietary interfaces. Use it to understand architecture and interoperability boundaries; preserve licenses and obtain permission before copying or redistributing any proprietary material.

## Next validation steps

- Identify the licenses for every dependency and bundled binary before redistribution.
- Determine which runtime APIs are specific to Nyxian.
- Keep the first Lara-Jailed implementation independent of undocumented entitlement assumptions.
- Test on a dedicated device and a clearly recorded iOS build before describing any capability as supported.
