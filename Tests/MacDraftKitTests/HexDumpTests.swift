import Foundation
import XCTest
@testable import MacDraftKit

final class HexDumpTests: XCTestCase {
    func testFormatsHexadecimalAndASCIIColumns() throws {
        let dump = try HexDump(data: Data([
            0x4D, 0x44, 0x37, 0x30, 0x30, 0x31, 0x00, 0x7F
        ]), bytesPerLine: 8)

        XCTAssertEqual(
            try dump.string(),
            "00000000  4D 44 37 30 30 31 00 7F  |MD7001..|"
        )
    }

    func testMultipleLinesIncludeAbsoluteOffsets() throws {
        let dump = try HexDump(data: Data(0..<20), bytesPerLine: 8)

        XCTAssertEqual(
            try dump.lines(),
            [
                "00000000  00 01 02 03 04 05 06 07  |........|",
                "00000008  08 09 0A 0B 0C 0D 0E 0F  |........|",
                "00000010  10 11 12 13              |....|"
            ]
        )
    }

    func testRangeBeginsAtRequestedOffset() throws {
        let dump = try HexDump(data: Data("0123456789".utf8), bytesPerLine: 4)

        XCTAssertEqual(
            try dump.lines(from: 3, count: 5),
            [
                "00000003  33 34 35 36  |3456|",
                "00000007  37           |7|"
            ]
        )
    }

    func testCountIsTruncatedAtEndOfData() throws {
        let dump = try HexDump(data: Data([0x41, 0x42]), bytesPerLine: 16)

        XCTAssertEqual(
            try dump.string(from: 1, count: 100),
            "00000001  42                                               |B|"
        )
    }

    func testZeroCountProducesNoLines() throws {
        let dump = try HexDump(data: Data([1, 2, 3]))

        XCTAssertEqual(try dump.lines(count: 0), [])
    }

    func testInvalidOffsetIsRejected() throws {
        let dump = try HexDump(data: Data([1, 2, 3]))

        XCTAssertThrowsError(try dump.lines(from: 4)) { error in
            XCTAssertEqual(
                error as? HexDumpError,
                .invalidOffset(4, dataCount: 3)
            )
        }
    }

    func testNegativeCountIsRejected() throws {
        let dump = try HexDump(data: Data())

        XCTAssertThrowsError(try dump.lines(count: -1)) { error in
            XCTAssertEqual(error as? HexDumpError, .negativeCount(-1))
        }
    }

    func testInvalidBytesPerLineIsRejected() {
        XCTAssertThrowsError(try HexDump(data: Data(), bytesPerLine: 0)) { error in
            XCTAssertEqual(error as? HexDumpError, .invalidBytesPerLine(0))
        }
    }
}
