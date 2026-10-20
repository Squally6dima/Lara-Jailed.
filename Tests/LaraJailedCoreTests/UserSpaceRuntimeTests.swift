import Foundation
import XCTest
@testable import LaraJailedCore

final class UserSpaceRuntimeTests: XCTestCase {
    private func makeFileSystem() throws -> (UserSpaceFileSystem, URL) {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent("LaraJailedTests-\(UUID().uuidString)", isDirectory: true)
        let fs = UserSpaceFileSystem(rootURL: base)
        try fs.prepare()
        return (fs, base)
    }

    func testPrepareCreatesContainerDirectories() throws {
        let (fs, root) = try makeFileSystem()
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("etc/motd").path))
        XCTAssertTrue(try fs.list("/").contains("usr"))
    }

    func testShellCanCreateAndReadFile() throws {
        let (fs, root) = try makeFileSystem()
        defer { try? FileManager.default.removeItem(at: root) }
        let shell = UserSpaceShell(fileSystem: fs)

        XCTAssertEqual(shell.execute("mkdir notes").output, "")
        XCTAssertEqual(shell.execute("touch notes/hello.txt").output, "")
        try fs.writeText("hello Lara", to: "notes/hello.txt")
        XCTAssertEqual(shell.execute("cat notes/hello.txt").output, "hello Lara")
    }

    func testShellChangesDirectory() throws {
        let (fs, root) = try makeFileSystem()
        defer { try? FileManager.default.removeItem(at: root) }
        let shell = UserSpaceShell(fileSystem: fs)
        _ = shell.execute("mkdir tmpdir")
        let changed = shell.execute("cd tmpdir")
        XCTAssertEqual(changed.currentDirectory, "/tmpdir")
        XCTAssertEqual(shell.execute("pwd", currentDirectory: changed.currentDirectory).output, "/tmpdir")
    }

    func testRejectsEscapingRoot() throws {
        let (fs, root) = try makeFileSystem()
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertThrowsError(try fs.resolve("../../outside"))
    }

    func testUnknownCommandDoesNotExecuteHostProcess() throws {
        let (fs, root) = try makeFileSystem()
        defer { try? FileManager.default.removeItem(at: root) }
        let result = UserSpaceShell(fileSystem: fs).execute("sh -c id")
        XCTAssertTrue(result.output.contains("command not found"))
    }
}
