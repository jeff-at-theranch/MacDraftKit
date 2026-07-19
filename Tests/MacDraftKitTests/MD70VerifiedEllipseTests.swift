import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedEllipseTests: XCTestCase {
    private static let topOffset = 0x09
    private static let leftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let bottomOffset = 0xCB
    private static let rightOffset = 0xD3

    private static let recordLength = 269
    private static let storageScale = 10.0
    private static let accuracy = 0.000_001

    func testDecodesResizedEllipseGeometry() throws {
        let record = makeEllipseRecord(
            top: 87.75,
            left: 98.75,
            bottom: 92.0,
            right: 105.5,
            penWidth: 1.0
        )

        let header = makeEllipseHeader(
            recordLength: record.count
        )

        let ellipse = MD70EllipseDecoder.decode(
            header: header,
            record: record
        )

        let anchor = try XCTUnwrap(ellipse.anchor)

        XCTAssertEqual(
            anchor.x,
            98.75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            87.75,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(ellipse.bounds)

        XCTAssertEqual(
            bounds.left,
            98.75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            87.75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            105.5,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            92.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            6.75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            4.25,
            accuracy: Self.accuracy
        )

        let penWidth = try XCTUnwrap(ellipse.penWidth)

        XCTAssertEqual(
            penWidth,
            1.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesMovedEllipseAnchorAndBounds() throws {
        let record = makeEllipseRecord(
            top: 100.0,
            left: 100.0,
            bottom: 100.0,
            right: 100.0,
            penWidth: 1.0
        )

        let header = makeEllipseHeader(
            recordLength: record.count
        )

        let ellipse = MD70EllipseDecoder.decode(
            header: header,
            record: record
        )

        let anchor = try XCTUnwrap(ellipse.anchor)

        XCTAssertEqual(
            anchor.x,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            100.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(ellipse.bounds)

        XCTAssertEqual(
            bounds.left,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            0.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            0.0,
            accuracy: Self.accuracy
        )
    }

    func testPreservesRawRecord() {
        let record = makeEllipseRecord(
            top: 87.75,
            left: 98.75,
            bottom: 92.0,
            right: 105.5,
            penWidth: 1.0
        )

        let header = makeEllipseHeader(
            recordLength: record.count
        )

        let ellipse = MD70EllipseDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertEqual(
            ellipse.rawRecord,
            record
        )
    }

    func testTruncatedRecordProducesNilGeometry() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let header = makeEllipseHeader(
            recordLength: record.count
        )

        let ellipse = MD70EllipseDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertNil(ellipse.anchor)
        XCTAssertNil(ellipse.bounds)
        XCTAssertNil(ellipse.penWidth)

        XCTAssertEqual(
            ellipse.rawRecord,
            record
        )
    }

    private func makeEllipseRecord(
        top: Double,
        left: Double,
        bottom: Double,
        right: Double,
        penWidth: Double
    ) -> Data {
        var record = Data(
            repeating: 0,
            count: Self.recordLength
        )

        writeFloat64BE(
            top * Self.storageScale,
            to: &record,
            at: Self.topOffset
        )

        writeFloat64BE(
            left * Self.storageScale,
            to: &record,
            at: Self.leftOffset
        )

        writeFloat64BE(
            penWidth,
            to: &record,
            at: Self.penWidthOffset
        )

        writeFloat64BE(
            bottom * Self.storageScale,
            to: &record,
            at: Self.bottomOffset
        )

        writeFloat64BE(
            right * Self.storageScale,
            to: &record,
            at: Self.rightOffset
        )

        return record
    }

    private func makeEllipseHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode: 0,
            type: .ellipse,
            storedLength: UInt32(
                max(0, recordLength - 12)
            )
        )
    }
    

    private func writeFloat64BE(
        _ value: Double,
        to data: inout Data,
        at offset: Int
    ) {
        let bits = value.bitPattern.bigEndian

        withUnsafeBytes(of: bits) { bytes in
            data.replaceSubrange(
                offset..<(offset + MemoryLayout<UInt64>.size),
                with: bytes
            )
        }
    }
}
