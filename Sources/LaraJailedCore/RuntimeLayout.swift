import Foundation

/// Paths owned by Lara-Jailed inside its own application container.
/// Protected iOS locations are intentionally out of scope.
public struct RuntimeLayout: Sendable {
    public let root: URL

    public init(applicationSupportDirectory: URL) {
        self.root = applicationSupportDirectory.appendingPathComponent("LaraJailed", isDirectory: true)
    }

    public var packagesDirectory: URL { root.appendingPathComponent("Packages", isDirectory: true) }
    public var packageDataDirectory: URL { root.appendingPathComponent("PackageData", isDirectory: true) }
    public var logsDirectory: URL { root.appendingPathComponent("Logs", isDirectory: true) }
    public var rootFSDirectory: URL { root.appendingPathComponent("RootFS", isDirectory: true) }

    public func prepare(fileManager: FileManager = .default) throws {
        for directory in [root, packagesDirectory, packageDataDirectory, logsDirectory, rootFSDirectory] {
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: 0o700]
            )
        }
    }

    public func dataDirectory(for packageID: String) throws -> URL {
        let manifest = PackageManifest(id: packageID, name: "Validation",
                                       version: "0.0.0", summary: "Validation only")
        try manifest.validate()
        return packageDataDirectory.appendingPathComponent(packageID, isDirectory: true)
    }
}
