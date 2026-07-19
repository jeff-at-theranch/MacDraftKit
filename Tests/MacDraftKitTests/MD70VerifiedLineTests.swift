import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedLineTests: XCTestCase {
    private static let startTopOffset = 0x09
    private static let startLeftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let endTopOffset = 0xCD
    private static let endLeftOffset = 0xD5

    private static let recordLength = 254
    private static let storageScale = 10.0
    private static let accuracy = 0.000_001

    func testDecodesOriginalLineGeometry() throws {
        let record = makeLineRecord(
            startX: 50.0,
            startY: 50.0,
            endX: 99.0,
            endY: 99.0,
            penWidth: 1.0
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        let startPoint = try XCTUnwrap(line.startPoint)

        XCTAssertEqual(
            startPoint.x,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            startPoint.y,
            50.0,
            accuracy: Self.accuracy
        )

        let endPoint = try XCTUnwrap(line.endPoint)

        XCTAssertEqual(
            endPoint.x,
            99.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            endPoint.y,
            99.0,
            accuracy: Self.accuracy
        )

        let anchor = try XCTUnwrap(line.anchor)

        XCTAssertEqual(
            anchor.x,
            startPoint.x,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            startPoint.y,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(line.bounds)

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
            99.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            99.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            49.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            49.0,
            accuracy: Self.accuracy
        )

        let length = try XCTUnwrap(
            lineLength(line)
        )

        XCTAssertEqual(
            length,
            69.296_464_556_281_66,
            accuracy: Self.accuracy
        )

        let penWidth = try XCTUnwrap(line.penWidth)

        XCTAssertEqual(
            penWidth,
            1.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesMovedLineGeometry() throws {
        let record = makeLineRecord(
            startX: 60.0,
            startY: 60.0,
            endX: 109.0,
            endY: 109.0,
            penWidth: 1.0
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        let startPoint = try XCTUnwrap(line.startPoint)

        XCTAssertEqual(
            startPoint.x,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            startPoint.y,
            60.0,
            accuracy: Self.accuracy
        )

        let endPoint = try XCTUnwrap(line.endPoint)

        XCTAssertEqual(
            endPoint.x,
            109.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            endPoint.y,
            109.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(line.bounds)

        XCTAssertEqual(
            bounds.left,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            109.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            109.0,
            accuracy: Self.accuracy
        )

        let length = try XCTUnwrap(
            lineLength(line)
        )

        XCTAssertEqual(
            length,
            69.296_464_556_281_66,
            accuracy: Self.accuracy
        )
    }

    func testDecodesResizedLineGeometry() throws {
        let component = 56.568_542_480_468_75

        let record = makeLineRecord(
            startX: 50.0,
            startY: 50.0,
            endX: 50.0 + component,
            endY: 50.0 + component,
            penWidth: 1.0
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        let startPoint = try XCTUnwrap(line.startPoint)

        XCTAssertEqual(
            startPoint.x,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            startPoint.y,
            50.0,
            accuracy: Self.accuracy
        )

        let endPoint = try XCTUnwrap(line.endPoint)

        XCTAssertEqual(
            endPoint.x,
            106.568_542_480_468_75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            endPoint.y,
            106.568_542_480_468_75,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(line.bounds)

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
            106.568_542_480_468_75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            106.568_542_480_468_75,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            component,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            component,
            accuracy: Self.accuracy
        )

        let length = try XCTUnwrap(
            lineLength(line)
        )

        XCTAssertEqual(
            length,
            80.0,
            accuracy: Self.accuracy
        )
    }

    func testComputesBoundsForReverseDirectionLine() throws {
        let record = makeLineRecord(
            startX: 100.0,
            startY: 80.0,
            endX: 40.0,
            endY: 20.0,
            penWidth: 2.0
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        let bounds = try XCTUnwrap(line.bounds)

        XCTAssertEqual(
            bounds.left,
            40.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            20.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            60.0,
            accuracy: Self.accuracy
        )
    }

    func testPreservesRawRecord() {
        let record = makeLineRecord(
            startX: 50.0,
            startY: 50.0,
            endX: 99.0,
            endY: 99.0,
            penWidth: 1.0
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertEqual(
            line.rawRecord,
            record
        )
    }

    func testTruncatedRecordProducesNilGeometry() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let header = makeLineHeader(
            recordLength: record.count
        )

        let line = MD70LineDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertNil(line.startPoint)
        XCTAssertNil(line.endPoint)
        XCTAssertNil(line.anchor)
        XCTAssertNil(line.bounds)
        XCTAssertNil(line.penWidth)

        XCTAssertEqual(
            line.rawRecord,
            record
        )
    }

    private func makeLineRecord(
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double,
        penWidth: Double
    ) -> Data {
        var record = Data(
            repeating: 0,
            count: Self.recordLength
        )

        writeFloat64BE(
            startY * Self.storageScale,
            to: &record,
            at: Self.startTopOffset
        )

        writeFloat64BE(
            startX * Self.storageScale,
            to: &record,
            at: Self.startLeftOffset
        )

        writeFloat64BE(
            penWidth,
            to: &record,
            at: Self.penWidthOffset
        )

        writeFloat64BE(
            endY * Self.storageScale,
            to: &record,
            at: Self.endTopOffset
        )

        writeFloat64BE(
            endX * Self.storageScale,
            to: &record,
            at: Self.endLeftOffset
        )

        return record
    }

    private func makeLineHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode: 0,
            type: .line,
            storedLength: UInt32(
                max(0, recordLength - 12)
            )
        )
    }

    private func lineLength(
        _ line: MD70Line
    ) -> Double? {
        guard
            let startPoint = line.startPoint,
            let endPoint = line.endPoint
        else {
            return nil
        }

        return hypot(
            endPoint.x - startPoint.x,
            endPoint.y - startPoint.y
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
