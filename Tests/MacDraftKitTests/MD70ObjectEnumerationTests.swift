import Foundation
import XCTest
@testable import MacDraftKit

final class MD70ObjectEnumerationTests: XCTestCase {
    func testEnumeratesTwoFixedStrideObjectRecords() throws {
        var data = Data(repeating: 0, count: 0x531B)

        writeUInt32LittleEndian(2, to: &data, at: 0x5117)

        writeObject(
            to: &data,
            at: 0x511B,
            centerX: 100,
            centerY: 100,
            radiusX: 37.5,
            radiusY: 37.5,
            penWidth: 1
        )
        writeObject(
            to: &data,
            at: 0x5228,
            centerX: 180.944,
            centerY: 100,
            radiusX: 37.5,
            radiusY: 37.5,
            penWidth: 1
        )

        let section = try XCTUnwrap(MD70ObjectSection.parse(from: data))

        XCTAssertEqual(section.declaredObjectCount, 2)
        XCTAssertEqual(section.objects.count, 2)
        XCTAssertEqual(section.firstObject, section.objects.first)

        XCTAssertEqual(section.objects[0].offset, 0x511B)
        XCTAssertEqual(section.objects[0].centerX, 100, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[0].centerY, 100, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[0].width, 75, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[0].height, 75, accuracy: 0.000_001)

        XCTAssertEqual(section.objects[1].offset, 0x5228)
        XCTAssertEqual(section.objects[1].centerX, 180.944, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[1].centerY, 100, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[1].width, 75, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[1].height, 75, accuracy: 0.000_001)
        XCTAssertEqual(section.objects[1].penWidth, 1, accuracy: 0.000_001)
    }

    func testStopsBeforeTruncatedDeclaredRecord() throws {
        var data = Data(repeating: 0, count: 0x5228)

        writeUInt32LittleEndian(2, to: &data, at: 0x5117)
        writeObject(
            to: &data,
            at: 0x511B,
            centerX: 40,
            centerY: 50,
            radiusX: 10,
            radiusY: 20,
            penWidth: 2
        )

        let section = try XCTUnwrap(MD70ObjectSection.parse(from: data))

        XCTAssertEqual(section.declaredObjectCount, 2)
        XCTAssertEqual(section.objects.count, 1)
    }

    private func writeObject(
        to data: inout Data,
        at offset: Int,
        centerX: Double,
        centerY: Double,
        radiusX: Float,
        radiusY: Float,
        penWidth: Double
    ) {
        writeFloat64BigEndian(centerY * 10, to: &data, at: offset + 0x09)
        writeFloat64BigEndian(centerX * 10, to: &data, at: offset + 0x11)
        writeFloat64BigEndian(penWidth, to: &data, at: offset + 0x69)
        writeFloat32BigEndian(radiusY * 10, to: &data, at: offset + 0xEB)
        writeFloat32BigEndian(radiusX * 10, to: &data, at: offset + 0xEF)
    }

    private func writeUInt32LittleEndian(
        _ value: UInt32,
        to data: inout Data,
        at offset: Int
    ) {
        let bytes: [UInt8] = [
            UInt8(truncatingIfNeeded: value),
            UInt8(truncatingIfNeeded: value >> 8),
            UInt8(truncatingIfNeeded: value >> 16),
            UInt8(truncatingIfNeeded: value >> 24),
        ]
        data.replaceSubrange(offset..<(offset + 4), with: bytes)
    }

    private func writeFloat32BigEndian(
        _ value: Float,
        to data: inout Data,
        at offset: Int
    ) {
        let bits = value.bitPattern
        let bytes: [UInt8] = [
            UInt8(truncatingIfNeeded: bits >> 24),
            UInt8(truncatingIfNeeded: bits >> 16),
            UInt8(truncatingIfNeeded: bits >> 8),
            UInt8(truncatingIfNeeded: bits),
        ]
        data.replaceSubrange(offset..<(offset + 4), with: bytes)
    }

    private func writeFloat64BigEndian(
        _ value: Double,
        to data: inout Data,
        at offset: Int
    ) {
        let bits = value.bitPattern
        let bytes: [UInt8] = [
            UInt8(truncatingIfNeeded: bits >> 56),
            UInt8(truncatingIfNeeded: bits >> 48),
            UInt8(truncatingIfNeeded: bits >> 40),
            UInt8(truncatingIfNeeded: bits >> 32),
            UInt8(truncatingIfNeeded: bits >> 24),
            UInt8(truncatingIfNeeded: bits >> 16),
            UInt8(truncatingIfNeeded: bits >> 8),
            UInt8(truncatingIfNeeded: bits),
        ]
        data.replaceSubrange(offset..<(offset + 8), with: bytes)
    }
}
