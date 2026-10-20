import Foundation

/// Metadata for a Lara-Jailed package. This does not execute scripts or grant privileges.
public struct PackageManifest: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let version: String
    public let summary: String
    public let minimumLaraVersion: String
    public let permissions: [String]

    public init(id: String, name: String, version: String, summary: String,
                minimumLaraVersion: String = "0.1.0", permissions: [String] = []) {
        self.id = id
        self.name = name
        self.version = version
        self.summary = summary
        self.minimumLaraVersion = minimumLaraVersion
        self.permissions = permissions
    }

    public func validate() throws {
        guard Self.isValidIdentifier(id) else { throw ManifestError.invalidIdentifier(id) }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ManifestError.emptyName
        }
        guard Self.isValidVersion(version) else { throw ManifestError.invalidVersion(version) }
        guard Self.isValidVersion(minimumLaraVersion) else {
            throw ManifestError.invalidVersion(minimumLaraVersion)
        }
        let invalid = permissions.filter { !Self.allowedPermissions.contains($0) }
        guard invalid.isEmpty else { throw ManifestError.unsupportedPermissions(invalid) }
    }

    public static let allowedPermissions: Set<String> = [
        "network.read",
        "files.user-selected.read",
        "files.user-selected.write",
        "notifications.request"
    ]

    private static func isValidIdentifier(_ value: String) -> Bool {
        guard !value.isEmpty, value.count <= 100 else { return false }
        return value.range(of: #"^[a-zA-Z0-9]+([.-][a-zA-Z0-9]+)*$"#,
                           options: .regularExpression) != nil
    }

    private static func isValidVersion(_ value: String) -> Bool {
        value.range(of: #"^[0-9]+\.[0-9]+\.[0-9]+([+-][a-zA-Z0-9.-]+)?$"#,
                    options: .regularExpression) != nil
    }
}

public enum ManifestError: Error, Equatable, LocalizedError {
    case invalidIdentifier(String)
    case emptyName
    case invalidVersion(String)
    case unsupportedPermissions([String])

    public var errorDescription: String? {
        switch self {
        case .invalidIdentifier(let value): return "Invalid package identifier: \(value)"
        case .emptyName: return "Package name must not be empty."
        case .invalidVersion(let value): return "Invalid version: \(value). Expected MAJOR.MINOR.PATCH."
        case .unsupportedPermissions(let values):
            return "Unsupported permissions: \(values.joined(separator: ", "))."
        }
    }
}
