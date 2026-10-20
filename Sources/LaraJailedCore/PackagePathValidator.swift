import Foundation

public enum PackagePathError: Error, Equatable, LocalizedError {
    case emptyPath
    case absolutePath(String)
    case traversalComponent(String)
    case invalidComponent(String)

    public var errorDescription: String? {
        switch self {
        case .emptyPath: return "Package file path must not be empty."
        case .absolutePath(let path): return "Absolute package path is not allowed: \(path)"
        case .traversalComponent(let path): return "Path traversal is not allowed: \(path)"
        case .invalidComponent(let path): return "Invalid path component: \(path)"
        }
    }
}

/// Validates archive entry names before a future installer writes anything.
/// This does not extract archives or grant access outside the app container.
public enum PackagePathValidator {
    public static func validateRelativePath(_ path: String) throws -> String {
        guard !path.isEmpty else { throw PackagePathError.emptyPath }
        guard !path.hasPrefix("/"), !path.hasPrefix("\\") else {
            throw PackagePathError.absolutePath(path)
        }
        guard !path.contains("\\") else { throw PackagePathError.invalidComponent(path) }

        let components = path.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        for component in components {
            guard !component.isEmpty, component != "." else {
                throw PackagePathError.invalidComponent(path)
            }
            guard component != ".." else { throw PackagePathError.traversalComponent(path) }
            guard !component.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
                throw PackagePathError.invalidComponent(path)
            }
        }
        return components.joined(separator: "/")
    }
}
