import XCTest
@testable import LaraJailedCore

final class PackagePathValidatorTests: XCTestCase {
    func testAcceptsRelativePath() throws {
        XCTAssertEqual(try PackagePathValidator.validateRelativePath("usr/bin/example"),
                       "usr/bin/example")
    }

    func testRejectsParentTraversal() {
        XCTAssertThrowsError(try PackagePathValidator.validateRelativePath("usr/../../outside"))
    }

    func testRejectsAbsolutePath() {
        XCTAssertThrowsError(try PackagePathValidator.validateRelativePath("/Library/example"))
    }

    func testRejectsBackslashPath() {
        XCTAssertThrowsError(try PackagePathValidator.validateRelativePath("usr\\..\\outside"))
    }

    func testRejectsEmptyComponents() {
        XCTAssertThrowsError(try PackagePathValidator.validateRelativePath("usr//bin"))
    }
}
