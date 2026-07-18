import Foundation
import XCTest
@testable import MacDraftKit

final class BinaryRangeDumpTests: XCTestCase {
    func testRendersOffsetsHexAndASCII() throws {
        let data = Data([0x41, 0x42, 0x00, 0x7E])
        let dump = try BinaryRangeDump(data: data, range: 0..<4, bytesPerLine: 4)
        XCTAssertEqual(dump.render(data: data), "00000000  41 42 00 7E  |AB.~|")
    }

    func testRejectsRangeOutsideData() {
        XCTAssertThrowsError(try BinaryRangeDump(data: Data([0]), range: 0..<2))
    }
}
