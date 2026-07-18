import Foundation
import XCTest
@testable import MacDraftKit

final class MD70ObjectTypeTests: XCTestCase {
    func testKnownObjectTypeCodes() {
        XCTAssertEqual(MD70ObjectType(rawValue: 0x01), .line)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x0A), .rectangle)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x0B), .roundedRectangle)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x15), .arc)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x18), .ellipse)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x20), .bezier)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x29), .text)
        XCTAssertEqual(MD70ObjectType(rawValue: 0x33), .polygon)
        XCTAssertNil(MD70ObjectType(rawValue: 0xFF))
    }

    func testDisplayNames() {
        XCTAssertEqual(MD70ObjectType.line.displayName, "Line")
        XCTAssertEqual(MD70ObjectType.rectangle.displayName, "Rectangle")
        XCTAssertEqual(MD70ObjectType.roundedRectangle.displayName, "Rounded rectangle")
        XCTAssertEqual(MD70ObjectType.arc.displayName, "Arc")
        XCTAssertEqual(MD70ObjectType.ellipse.displayName, "Ellipse")
        XCTAssertEqual(MD70ObjectType.bezier.displayName, "Bezier")
        XCTAssertEqual(MD70ObjectType.text.displayName, "Text")
        XCTAssertEqual(MD70ObjectType.polygon.displayName, "Polygon")
    }

    func testRecordDecodesKnownAndUnknownTypeCodes() throws {
        var data = makeRecord(typeCode: 0x18)

        let knownSection = try XCTUnwrap(MD70ObjectSection.parse(from: data))
        let knownObject = try XCTUnwrap(knownSection.firstObject)
        XCTAssertEqual(knownObject.rawTypeCode, 0x18)
        XCTAssertEqual(knownObject.type, .ellipse)

        data[0x511B] = 0xFE

        let unknownSection = try XCTUnwrap(MD70ObjectSection.parse(from: data))
        let unknownObject = try XCTUnwrap(unknownSection.firstObject)
        XCTAssertEqual(unknownObject.rawTypeCode, 0xFE)
        XCTAssertNil(unknownObject.type)
    }

    private func makeRecord(typeCode: UInt8) -> Data {
        var data = Data(repeating: 0, count: 0x520E)
        data[0x5117] = 1
        data[0x511B] = typeCode

        writeFloat64BigEndian(1_000, to: &data, at: 0x5124)
        writeFloat64BigEndian(1_000, to: &data, at: 0x512C)
        writeFloat64BigEndian(1, to: &data, at: 0x5184)
        writeFloat32BigEndian(375, to: &data, at: 0x5206)
        writeFloat32BigEndian(375, to: &data, at: 0x520A)

        return data
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
