import Foundation

public enum UserSpaceFileError: Error, Equatable, LocalizedError {
    case invalidPath(String)
    case notFound(String)
    case alreadyExists(String)
    case notDirectory(String)
    case isDirectory(String)
    case unsupportedOperation(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path): return "Invalid path: \(path)"
        case .notFound(let path): return "Not found: \(path)"
        case .alreadyExists(let path): return "Already exists: \(path)"
        case .notDirectory(let path): return "Not a directory: \(path)"
        case .isDirectory(let path): return "Is a directory: \(path)"
        case .unsupportedOperation(let operation): return "Unsupported operation: \(operation)"
        }
    }
}

/// A small virtual filesystem rooted entirely inside Lara's app container.
/// This is not a mount of iOS / and cannot access protected system files.
public struct UserSpaceFileSystem: Sendable {
    public let rootURL: URL
    private let fm = FileManager.default

    public init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
    }

    public func prepare() throws {
        try fm.createDirectory(at: rootURL, withIntermediateDirectories: true,
                               attributes: [.posixPermissions: 0o700])
        for path in ["bin", "etc", "tmp", "home", "home/lar a", "usr", "usr/bin", "var", "var/log", "var/cache", "Applications", "Packages"] {
            let cleanPath = path.replacingOccurrences(of: "lar a", with: "lara")
            try createDirectory(cleanPath, intermediates: true)
        }
        let motd = resolve("etc/motd")
        if !fm.fileExists(atPath: motd.path) {
            try Data("Welcome to Lara user space. This is a container-local prototype.\n".utf8)
                .write(to: motd, options: .atomic)
        }
    }

    public func resolve(_ path: String, currentDirectory: String = "/") throws -> URL {
        let input = path.isEmpty ? currentDirectory : path
        let components = (input.hasPrefix("/") ? [] : currentDirectory.split(separator: "/").map(String.init))
            + input.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        var stack: [String] = []
        for component in components {
            if component == "." { continue }
            if component == ".." {
                guard !stack.isEmpty else { throw UserSpaceFileError.invalidPath(path) }
                stack.removeLast()
            } else {
                guard !component.contains("\\"), !component.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
                    throw UserSpaceFileError.invalidPath(path)
                }
                stack.append(component)
            }
        }
        let url = stack.reduce(rootURL) { $0.appendingPathComponent($1, isDirectory: false) }.standardizedFileURL
        guard url.path == rootURL.path || url.path.hasPrefix(rootURL.path + "/") else {
            throw UserSpaceFileError.invalidPath(path)
        }
        return url
    }

    public func virtualPath(for url: URL) -> String {
        let relative = url.standardizedFileURL.path.replacingOccurrences(of: rootURL.path, with: "")
        return relative.isEmpty ? "/" : relative
    }

    public func list(_ path: String = ".", currentDirectory: String = "/") throws -> [String] {
        let url = try resolve(path, currentDirectory: currentDirectory)
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw UserSpaceFileError.notFound(path)
        }
        guard isDirectory.boolValue else { throw UserSpaceFileError.notDirectory(path) }
        return try fm.contentsOfDirectory(atPath: url.path).sorted()
    }

    public func readText(_ path: String, currentDirectory: String = "/") throws -> String {
        let url = try resolve(path, currentDirectory: currentDirectory)
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw UserSpaceFileError.notFound(path)
        }
        guard !isDirectory.boolValue else { throw UserSpaceFileError.isDirectory(path) }
        return try String(contentsOf: url, encoding: .utf8)
    }

    public func writeText(_ text: String, to path: String, currentDirectory: String = "/",
                          createParents: Bool = false) throws {
        let url = try resolve(path, currentDirectory: currentDirectory)
        if createParents {
            try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        try requireParentDirectory(url, virtualPath: path)
        try Data(text.utf8).write(to: url, options: .atomic)
    }

    public func createDirectory(_ path: String, currentDirectory: String = "/", intermediates: Bool = false) throws {
        let url = try resolve(path, currentDirectory: currentDirectory)
        if fm.fileExists(atPath: url.path) { throw UserSpaceFileError.alreadyExists(path) }
        try requireParentDirectory(url, virtualPath: path, allowMissingParent: intermediates)
        try fm.createDirectory(at: url, withIntermediateDirectories: intermediates,
                               attributes: [.posixPermissions: 0o700])
    }

    public func createFile(_ path: String, currentDirectory: String = "/") throws {
        let url = try resolve(path, currentDirectory: currentDirectory)
        if fm.fileExists(atPath: url.path) { throw UserSpaceFileError.alreadyExists(path) }
        try requireParentDirectory(url, virtualPath: path)
        guard fm.createFile(atPath: url.path, contents: Data(), attributes: [.posixPermissions: 0o600]) else {
            throw UserSpaceFileError.unsupportedOperation("touch \(path)")
        }
    }

    public func remove(_ path: String, currentDirectory: String = "/") throws {
        let url = try resolve(path, currentDirectory: currentDirectory)
        guard url.path != rootURL.path else { throw UserSpaceFileError.invalidPath(path) }
        guard fm.fileExists(atPath: url.path) else { throw UserSpaceFileError.notFound(path) }
        try fm.removeItem(at: url)
    }

    public func changeDirectory(_ path: String, currentDirectory: String = "/") throws -> String {
        let url = try resolve(path, currentDirectory: currentDirectory)
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw UserSpaceFileError.notFound(path)
        }
        guard isDirectory.boolValue else { throw UserSpaceFileError.notDirectory(path) }
        return virtualPath(for: url)
    }

    private func requireParentDirectory(_ url: URL, virtualPath: String, allowMissingParent: Bool = false) throws {
        let parent = url.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: parent.path, isDirectory: &isDirectory) else {
            if allowMissingParent { return }
            throw UserSpaceFileError.notFound(virtualPath)
        }
        guard isDirectory.boolValue else { throw UserSpaceFileError.notDirectory(virtualPath) }
    }
}
