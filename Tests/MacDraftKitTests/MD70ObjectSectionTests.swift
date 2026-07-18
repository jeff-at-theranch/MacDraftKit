import Foundation
import XCTest
@testable import MacDraftKit

final class MD70ObjectSectionTests: XCTestCase {
    func testDecodesConfirmedFirstObjectFields() throws {
        let data = makeDocument(
            objectCount: 1,
            centerX: 110,
            centerY: 100,
            radiusX: 37.5,
            radiusY: 25,
            penWidth: 5
        )

        let document = try MacDraftDocument(data: data)
        let section = try XCTUnwrap(document.objectSection)
        let object = try XCTUnwrap(section.firstObject)

        XCTAssertEqual(section.declaredObjectCount, 1)
        XCTAssertEqual(object.offset, 0x511B)
        XCTAssertEqual(object.centerX, 110, accuracy: 0.0001)
        XCTAssertEqual(object.centerY, 100, accuracy: 0.0001)
        XCTAssertEqual(object.radiusX, 37.5, accuracy: 0.0001)
        XCTAssertEqual(object.radiusY, 25, accuracy: 0.0001)
        XCTAssertEqual(object.width, 75, accuracy: 0.0001)
        XCTAssertEqual(object.height, 50, accuracy: 0.0001)
        XCTAssertEqual(object.penWidth, 5, accuracy: 0.0001)
    }

    func testZeroObjectDocumentHasNoFirstObject() throws {
        let document = try MacDraftDocument(data: makeDocument(objectCount: 0))
        XCTAssertEqual(document.objectSection?.declaredObjectCount, 0)
        XCTAssertNil(document.objectSection?.firstObject)
    }

    func testShortDocumentDoesNotClaimAnObjectSection() throws {
        let document = try MacDraftDocument(data: Data("MD7020payload".utf8))
        XCTAssertNil(document.objectSection)
    }

    private func makeDocument(
        objectCount: UInt32,
        centerX: Double = 0,
        centerY: Double = 0,
        radiusX: Float = 0,
        radiusY: Float = 0,
        penWidth: Double = 1
    ) -> Data {
        var data = Data(repeating: 0, count: 0x520E)
        data.replaceSubrange(0..<6, with: Data("MD7020".utf8))
        writeUInt32LE(objectCount, to: &data, at: 0x5117)
        guard objectCount > 0 else { return data }
        writeFloat64BE(centerY * 10, to: &data, at: 0x5124)
        writeFloat64BE(centerX * 10, to: &data, at: 0x512C)
        writeFloat64BE(penWidth, to: &data, at: 0x5184)
        writeFloat32BE(radiusY * 10, to: &data, at: 0x5206)
        writeFloat32BE(radiusX * 10, to: &data, at: 0x520A)
        return data
    }

    private func writeUInt32LE(_ value: UInt32, to data: inout Data, at offset: Int) {
        for index in 0..<4 {
            data[offset + index] = UInt8(truncatingIfNeeded: value >> UInt32(index * 8))
        }
    }

    private func writeFloat32BE(_ value: Float, to data: inout Data, at offset: Int) {
        writeUInt32BE(value.bitPattern, to: &data, at: offset)
    }

    private func writeFloat64BE(_ value: Double, to data: inout Data, at offset: Int) {
        let bits = value.bitPattern
        for index in 0..<8 {
            let shift = UInt64((7 - index) * 8)
            data[offset + index] = UInt8(truncatingIfNeeded: bits >> shift)
        }
    }

    private func writeUInt32BE(_ value: UInt32, to data: inout Data, at offset: Int) {
        for index in 0..<4 {
            let shift = UInt32((3 - index) * 8)
            data[offset + index] = UInt8(truncatingIfNeeded: value >> shift)
        }
    }
}
