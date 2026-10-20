import Foundation
import XCTest
@testable import LaraJailedCore

final class PackageManifestTests: XCTestCase {
    func testAcceptsValidManifest() throws {
        let manifest = PackageManifest(id: "org.example.clock", name: "Clock Widget",
                                       version: "1.2.0", summary: "Example package",
                                       permissions: ["network.read"])
        XCTAssertNoThrow(try manifest.validate())
    }

    func testRejectsPathTraversalIdentifier() {
        let manifest = PackageManifest(id: "../outside", name: "Unsafe",
                                       version: "1.0.0", summary: "Invalid identifier")
        XCTAssertThrowsError(try manifest.validate())
    }

    func testRejectsUnsupportedPermission() {
        let manifest = PackageManifest(id: "org.example.bad", name: "Bad",
                                       version: "1.0.0", summary: "Invalid permission",
                                       permissions: ["kernel.access"])
        XCTAssertThrowsError(try manifest.validate())
    }

    func testDecoderValidatesInput() throws {
        let json = #"{"id":"org.example.demo","name":"Demo","version":"1.0.0","summary":"A demo","minimumLaraVersion":"0.1.0","permissions":[]}"#
        let manifest = try ManifestDecoder.decode(Data(json.utf8))
        XCTAssertEqual(manifest.id, "org.example.demo")
    }

    func testRuntimeLayoutRejectsTraversal() {
        let layout = RuntimeLayout(applicationSupportDirectory: URL(fileURLWithPath: "/tmp/test"))
        XCTAssertThrowsError(try layout.dataDirectory(for: "../../tmp"))
        XCTAssertEqual(try? layout.dataDirectory(for: "org.example.demo").lastPathComponent,
                       "org.example.demo")
    }
}
