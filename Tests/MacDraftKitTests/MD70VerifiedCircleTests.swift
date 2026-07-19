import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedCircleTests: XCTestCase {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let radiusOffset = 0xCB

    private static let recordLength = 333
    private static let storageScale = 10.0
    private static let accuracy = 0.000_001

    func testDecodesOriginalCircleGeometry() throws {
        let record = makeCircleRecord(
            anchorX: 80.0,
            anchorY: 80.0,
            radius: 37.5,
            penWidth: 1.0
        )

        let header = makeCircleHeader(
            recordLength: record.count
        )

        let circle = MD70CircleDecoder.decode(
            header: header,
            record: record
        )

        let anchor = try XCTUnwrap(circle.anchor)

        XCTAssertEqual(
            anchor.x,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            80.0,
            accuracy: Self.accuracy
        )

        let radius = try XCTUnwrap(circle.radius)

        XCTAssertEqual(
            radius,
            37.5,
            accuracy: Self.accuracy
        )

        let diameter = try XCTUnwrap(circle.diameter)

        XCTAssertEqual(
            diameter,
            75.0,
            accuracy: Self.accuracy
        )

        let center = try XCTUnwrap(circle.center)

        XCTAssertEqual(
            center.x,
            106.516_504_294_495_53,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            center.y,
            106.516_504_294_495_53,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(circle.bounds)

        XCTAssertEqual(
            bounds.left,
            69.016_504_294_495_53,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            69.016_504_294_495_53,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            144.016_504_294_495_53,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            144.016_504_294_495_53,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            75.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            75.0,
            accuracy: Self.accuracy
        )

        let penWidth = try XCTUnwrap(circle.penWidth)

        XCTAssertEqual(
            penWidth,
            1.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesResizedCircleGeometry() throws {
        let storedRadius = 25.000_006_103_515_6

        let record = makeCircleRecord(
            anchorX: 80.0,
            anchorY: 80.0,
            radius: storedRadius,
            penWidth: 1.0
        )

        let header = makeCircleHeader(
            recordLength: record.count
        )

        let circle = MD70CircleDecoder.decode(
            header: header,
            record: record
        )

        let anchor = try XCTUnwrap(circle.anchor)

        XCTAssertEqual(
            anchor.x,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            80.0,
            accuracy: Self.accuracy
        )

        let radius = try XCTUnwrap(circle.radius)

        XCTAssertEqual(
            radius,
            storedRadius,
            accuracy: Self.accuracy
        )

        let diameter = try XCTUnwrap(circle.diameter)

        XCTAssertEqual(
            diameter,
            storedRadius * 2.0,
            accuracy: Self.accuracy
        )

        let expectedCenterComponent =
            storedRadius / sqrt(2.0)

        let center = try XCTUnwrap(circle.center)

        XCTAssertEqual(
            center.x,
            80.0 + expectedCenterComponent,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            center.y,
            80.0 + expectedCenterComponent,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(circle.bounds)

        XCTAssertEqual(
            bounds.left,
            center.x - storedRadius,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            center.y - storedRadius,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            center.x + storedRadius,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            center.y + storedRadius,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            storedRadius * 2.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            storedRadius * 2.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesMovedCircleGeometry() throws {
        let storedRadius = 25.000_006_103_515_6

        let record = makeCircleRecord(
            anchorX: 100.0,
            anchorY: 100.0,
            radius: storedRadius,
            penWidth: 1.0
        )

        let header = makeCircleHeader(
            recordLength: record.count
        )

        let circle = MD70CircleDecoder.decode(
            header: header,
            record: record
        )

        let anchor = try XCTUnwrap(circle.anchor)

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

        let radius = try XCTUnwrap(circle.radius)

        XCTAssertEqual(
            radius,
            storedRadius,
            accuracy: Self.accuracy
        )

        let expectedCenterComponent =
            storedRadius / sqrt(2.0)

        let center = try XCTUnwrap(circle.center)

        XCTAssertEqual(
            center.x,
            100.0 + expectedCenterComponent,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            center.y,
            100.0 + expectedCenterComponent,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(circle.bounds)

        XCTAssertEqual(
            bounds.width,
            storedRadius * 2.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            storedRadius * 2.0,
            accuracy: Self.accuracy
        )
    }

    func testPreservesRawRecord() {
        let record = makeCircleRecord(
            anchorX: 80.0,
            anchorY: 80.0,
            radius: 37.5,
            penWidth: 1.0
        )

        let header = makeCircleHeader(
            recordLength: record.count
        )

        let circle = MD70CircleDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertEqual(
            circle.rawRecord,
            record
        )
    }

    func testTruncatedRecordProducesNilGeometry() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let header = makeCircleHeader(
            recordLength: record.count
        )

        let circle = MD70CircleDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertNil(circle.anchor)
        XCTAssertNil(circle.center)
        XCTAssertNil(circle.radius)
        XCTAssertNil(circle.diameter)
        XCTAssertNil(circle.bounds)
        XCTAssertNil(circle.penWidth)

        XCTAssertEqual(
            circle.rawRecord,
            record
        )
    }

    private func makeCircleRecord(
        anchorX: Double,
        anchorY: Double,
        radius: Double,
        penWidth: Double
    ) -> Data {
        var record = Data(
            repeating: 0,
            count: Self.recordLength
        )

        writeFloat64BE(
            anchorY * Self.storageScale,
            to: &record,
            at: Self.anchorTopOffset
        )

        writeFloat64BE(
            anchorX * Self.storageScale,
            to: &record,
            at: Self.anchorLeftOffset
        )

        writeFloat64BE(
            penWidth,
            to: &record,
            at: Self.penWidthOffset
        )

        writeFloat64BE(
            radius * Self.storageScale,
            to: &record,
            at: Self.radiusOffset
        )

        return record
    }

    private func makeCircleHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode: 0,
            type: .circle,
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
