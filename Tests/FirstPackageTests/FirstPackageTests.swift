import XCTest
@testable import FirstPackage

final class FirstPackageTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FirstPackage().text, "Hello, World!")
    }
}
