import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedGeometryTests: XCTestCase {
    func testRectangleUsesVerifiedBoundsOffsets() throws {
        var data = Data(repeating: 0, count: 0x5400)
        writeUInt32LE(1, to: &data, at: MD70ObjectSection.objectCountOffset)

        let base = MD70ObjectSection.firstObjectOffset
        data[base] = MD70ObjectType.rectangle.rawValue
        writeUInt32BE(0x14E, to: &data, at: base + 1)

        writeFloat64BE(700, to: &data, at: base + 0x09)
        writeFloat64BE(700, to: &data, at: base + 0x11)
        writeFloat64BE(1700, to: &data, at: base + 0xEF)
        writeFloat64BE(900, to: &data, at: base + 0x107)

        let section = try XCTUnwrap(MD70ObjectSection.parse(from: data))
        let rectangle = try XCTUnwrap(section.firstObject as? MD70Rectangle)
        let bounds = try XCTUnwrap(rectangle.bounds)

        XCTAssertEqual(rectangle.anchor, MD70Point(x: 70, y: 70))
        XCTAssertEqual(bounds.left, 70)
        XCTAssertEqual(bounds.top, 70)
        XCTAssertEqual(bounds.right, 170)
        XCTAssertEqual(bounds.bottom, 90)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 20)
    }

    func testUnknownObjectIsPreservedAndTraversed() throws {
        var data = Data(repeating: 0, count: 0x5400)
        writeUInt32LE(2, to: &data, at: MD70ObjectSection.objectCountOffset)

        let first = MD70ObjectSection.firstObjectOffset
        data[first] = 0xFE
        writeUInt32BE(0x24, to: &data, at: first + 1)

        let second = first + 0x30
        data[second] = MD70ObjectType.rectangle.rawValue
        writeUInt32BE(0x14E, to: &data, at: second + 1)

        let section = try XCTUnwrap(MD70ObjectSection.parse(from: data))
        XCTAssertEqual(section.objects.count, 2)
        XCTAssertTrue(section.objects[0] is MD70UnknownObject)
        XCTAssertTrue(section.objects[1] is MD70Rectangle)
        XCTAssertEqual(section.objects[1].offset, second)
    }

    private func writeUInt32LE(_ value: UInt32, to data: inout Data, at offset: Int) {
        for index in 0..<4 {
            data[offset + index] = UInt8(truncatingIfNeeded: value >> UInt32(index * 8))
        }
    }

    private func writeUInt32BE(_ value: UInt32, to data: inout Data, at offset: Int) {
        for index in 0..<4 {
            let shift = UInt32((3 - index) * 8)
            data[offset + index] = UInt8(truncatingIfNeeded: value >> shift)
        }
    }

    private func writeFloat64BE(_ value: Double, to data: inout Data, at offset: Int) {
        let bits = value.bitPattern
        for index in 0..<8 {
            let shift = UInt64((7 - index) * 8)
            data[offset + index] = UInt8(truncatingIfNeeded: bits >> shift)
        }
    }
}
