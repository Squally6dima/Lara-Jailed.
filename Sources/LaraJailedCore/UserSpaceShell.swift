import Foundation

public struct ShellResult: Equatable, Sendable {
    public let output: String
    public let currentDirectory: String
    public let shouldExit: Bool

    public init(output: String, currentDirectory: String, shouldExit: Bool = false) {
        self.output = output
        self.currentDirectory = currentDirectory
        self.shouldExit = shouldExit
    }
}

/// Deliberately small command interpreter. It never invokes /bin/sh or host processes.
public struct UserSpaceShell: Sendable {
    public let fileSystem: UserSpaceFileSystem
    public init(fileSystem: UserSpaceFileSystem) { self.fileSystem = fileSystem }

    public func execute(_ line: String, currentDirectory: String = "/") -> ShellResult {
        let args = Self.tokenize(line)
        guard let command = args.first else {
            return ShellResult(output: "", currentDirectory: currentDirectory)
        }
        let rest = Array(args.dropFirst())
        do {
            switch command {
            case "help":
                return result("Commands: help, pwd, ls, cd, cat, echo, mkdir, touch, rm, clear, whoami, uname, exit", currentDirectory)
            case "pwd":
                return result(currentDirectory, currentDirectory)
            case "ls":
                let target = rest.first ?? "."
                let entries = try fileSystem.list(target, currentDirectory: currentDirectory)
                return result(entries.isEmpty ? "" : entries.joined(separator: "  "), currentDirectory)
            case "cd":
                return ShellResult(output: "", currentDirectory: try fileSystem.changeDirectory(rest.first ?? "/",
                                                                                              currentDirectory: currentDirectory))
            case "cat":
                guard let path = rest.first else { return result("usage: cat <file>", currentDirectory) }
                return result(try fileSystem.readText(path, currentDirectory: currentDirectory), currentDirectory)
            case "echo":
                return result(rest.joined(separator: " "), currentDirectory)
            case "mkdir":
                guard let path = rest.first else { return result("usage: mkdir <directory>", currentDirectory) }
                try fileSystem.createDirectory(path, currentDirectory: currentDirectory)
                return result("", currentDirectory)
            case "touch":
                guard let path = rest.first else { return result("usage: touch <file>", currentDirectory) }
                try fileSystem.createFile(path, currentDirectory: currentDirectory)
                return result("", currentDirectory)
            case "rm":
                guard let path = rest.first else { return result("usage: rm <file-or-directory>", currentDirectory) }
                try fileSystem.remove(path, currentDirectory: currentDirectory)
                return result("", currentDirectory)
            case "whoami":
                return result("lara", currentDirectory)
            case "uname":
                return result("Lara-UserSpace", currentDirectory)
            case "clear":
                return result("\u{001B}[2J\u{001B}[H", currentDirectory)
            case "exit":
                return ShellResult(output: "Leaving terminal session.", currentDirectory: currentDirectory, shouldExit: true)
            default:
                return result("\(command): command not found (type help)", currentDirectory)
            }
        } catch {
            return result("error: \(error.localizedDescription)", currentDirectory)
        }
    }

    private func result(_ output: String, _ directory: String) -> ShellResult {
        ShellResult(output: output, currentDirectory: directory)
    }

    private static func tokenize(_ input: String) -> [String] {
        var result: [String] = []
        var token = ""
        var quote: Character?
        var escaping = false
        for character in input {
            if escaping { token.append(character); escaping = false; continue }
            if character == "\\" { escaping = true; continue }
            if let activeQuote = quote {
                if character == activeQuote { quote = nil } else { token.append(character) }
                continue
            }
            if character == "\"" || character == "'" { quote = character; continue }
            if character.isWhitespace {
                if !token.isEmpty { result.append(token); token = "" }
            } else {
                token.append(character)
            }
        }
        if escaping { token.append("\\") }
        if !token.isEmpty { result.append(token) }
        return result
    }
}
