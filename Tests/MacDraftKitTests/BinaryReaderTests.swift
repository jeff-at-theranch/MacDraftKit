import Foundation
import XCTest
@testable import MacDraftKit

final class BinaryReaderTests: XCTestCase {
    func testInitialState() throws {
        let reader = try BinaryReader(data: Data([0x10, 0x20, 0x30]))

        XCTAssertEqual(reader.offset, 0)
        XCTAssertEqual(reader.remainingCount, 3)
        XCTAssertFalse(reader.isAtEnd)
    }

    func testReadUInt8AdvancesOffset() throws {
        var reader = try BinaryReader(data: Data([0xAB, 0xCD]))

        XCTAssertEqual(try reader.readUInt8(), 0xAB)
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.remainingCount, 1)
    }

    func testReadLittleEndianIntegers() throws {
        var reader = try BinaryReader(
            data: Data([
                0x34, 0x12,
                0x78, 0x56, 0x34, 0x12
            ])
        )

        let uint16: UInt16 = try reader.readInteger()
        let uint32: UInt32 = try reader.readInteger()

        XCTAssertEqual(uint16, 0x1234)
        XCTAssertEqual(uint32, 0x12345678)
        XCTAssertTrue(reader.isAtEnd)
    }

    func testReadBigEndianInteger() throws {
        var reader = try BinaryReader(data: Data([0x12, 0x34, 0x56, 0x78]))

        let value: UInt32 = try reader.readInteger(byteOrder: .bigEndian)

        XCTAssertEqual(value, 0x12345678)
    }

    func testReadSignedIntegerPreservesBitPattern() throws {
        var reader = try BinaryReader(data: Data([0xFF, 0xFF]))

        let value: Int16 = try reader.readInteger()

        XCTAssertEqual(value, -1)
    }

    func testSeekAndSkip() throws {
        var reader = try BinaryReader(data: Data([0, 1, 2, 3, 4]))

        try reader.seek(to: 1)
        try reader.skip(2)

        XCTAssertEqual(reader.offset, 3)
        XCTAssertEqual(try reader.readUInt8(), 3)
    }

    func testReadDataReturnsRequestedSlice() throws {
        var reader = try BinaryReader(data: Data([1, 2, 3, 4]))

        let result = try reader.readData(count: 2)

        XCTAssertEqual(result, Data([1, 2]))
        XCTAssertEqual(reader.offset, 2)
    }

    func testOutOfBoundsReadDoesNotAdvanceOffset() throws {
        var reader = try BinaryReader(data: Data([1, 2]))

        XCTAssertThrowsError(try reader.readData(count: 3)) { error in
            XCTAssertEqual(
                error as? BinaryReaderError,
                .outOfBounds(offset: 0, requestedCount: 3, remainingCount: 2)
            )
        }

        XCTAssertEqual(reader.offset, 0)
    }

    func testInvalidSeekDoesNotChangeOffset() throws {
        var reader = try BinaryReader(data: Data([1, 2, 3]), offset: 1)

        XCTAssertThrowsError(try reader.seek(to: 4)) { error in
            XCTAssertEqual(
                error as? BinaryReaderError,
                .invalidOffset(4, dataCount: 3)
            )
        }

        XCTAssertEqual(reader.offset, 1)
    }

    func testNegativeCountIsRejected() throws {
        var reader = try BinaryReader(data: Data())

        XCTAssertThrowsError(try reader.readData(count: -1)) { error in
            XCTAssertEqual(error as? BinaryReaderError, .negativeCount(-1))
        }
    }
}
