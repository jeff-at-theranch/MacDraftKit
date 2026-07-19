import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedRoundedRectangleTests:
    XCTestCase
{
    private static let topOffset = 0x09
    private static let leftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let rightOffset = 0xEF
    private static let bottomOffset = 0x107
    private static let cornerWidthOffset = 0x153
    private static let cornerHeightOffset = 0x15B

    private static let recordLength = 389
    private static let storageScale = 10.0
    private static let accuracy = 0.000_001

    func testDecodesOriginalGeometry() throws {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        let anchor = try XCTUnwrap(
            roundedRectangle.anchor
        )

        XCTAssertEqual(
            anchor.x,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            50.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            130.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            90.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            10.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            10.0,
            accuracy: Self.accuracy
        )

        let penWidth = try XCTUnwrap(
            roundedRectangle.penWidth
        )

        XCTAssertEqual(
            penWidth,
            1.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesMovedGeometry() throws {
        let record = makeRoundedRectangleRecord(
            top: 60.0,
            left: 70.0,
            right: 150.0,
            bottom: 100.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        let anchor = try XCTUnwrap(
            roundedRectangle.anchor
        )

        XCTAssertEqual(
            anchor.x,
            70.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            60.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            70.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            150.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            10.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            10.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesResizedGeometry() throws {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 150.0,
            bottom: 110.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            150.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            110.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            60.0,
            accuracy: Self.accuracy
        )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            20.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesChangedCornerRadius() throws {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 40.0,
            cornerHeight: 40.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            20.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )
    }

    func testSupportsDifferentHorizontalAndVerticalRadii()
        throws
    {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 30.0,
            cornerHeight: 16.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            15.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            8.0,
            accuracy: Self.accuracy
        )
    }

    func testPreservesRawRecord() {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            penWidth: 1.0
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        XCTAssertEqual(
            roundedRectangle.rawRecord,
            record
        )
    }

    func testTruncatedRecordProducesNilGeometry() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let header = makeHeader(
            recordLength: record.count
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        XCTAssertNil(roundedRectangle.anchor)
        XCTAssertNil(roundedRectangle.bounds)
        XCTAssertNil(roundedRectangle.cornerWidth)
        XCTAssertNil(roundedRectangle.cornerHeight)
        XCTAssertNil(roundedRectangle.cornerRadiusX)
        XCTAssertNil(roundedRectangle.cornerRadiusY)
        XCTAssertNil(roundedRectangle.penWidth)

        XCTAssertEqual(
            roundedRectangle.rawRecord,
            record
        )
    }

    private func makeRoundedRectangleRecord(
        top: Double,
        left: Double,
        right: Double,
        bottom: Double,
        cornerWidth: Double,
        cornerHeight: Double,
        penWidth: Double
    ) -> Data {
        var record = Data(
            repeating: 0,
            count: Self.recordLength
        )

        writeScaledFloat64BE(
            top,
            to: &record,
            at: Self.topOffset
        )

        writeScaledFloat64BE(
            left,
            to: &record,
            at: Self.leftOffset
        )

        writeFloat64BE(
            penWidth,
            to: &record,
            at: Self.penWidthOffset
        )

        writeScaledFloat64BE(
            right,
            to: &record,
            at: Self.rightOffset
        )

        writeScaledFloat64BE(
            bottom,
            to: &record,
            at: Self.bottomOffset
        )

        writeScaledFloat64BE(
            cornerWidth,
            to: &record,
            at: Self.cornerWidthOffset
        )

        writeScaledFloat64BE(
            cornerHeight,
            to: &record,
            at: Self.cornerHeightOffset
        )

        return record
    }

    private func makeHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode: 0,
            type: .roundedRectangle,
            storedLength: UInt32(
                max(0, recordLength - 12)
            )
        )
    }

    private func writeScaledFloat64BE(
        _ value: Double,
        to data: inout Data,
        at offset: Int
    ) {
        writeFloat64BE(
            value * Self.storageScale,
            to: &data,
            at: offset
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
