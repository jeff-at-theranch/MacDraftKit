import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedBezierTests: XCTestCase {
    private static let anchorYOffset = 0x09
    private static let anchorXOffset = 0x11

    private static let pointCountOffset = 0xCC
    private static let pointTableOffset = 0xD0
    private static let pointStride = 0x20

    private static let pointYOffset = 0x00
    private static let pointXOffset = 0x08

    func testDecodesCubicSegmentsAndStyle() throws {
        let points = [
            MD70Point(x: 20, y: 80),

            MD70Point(x: 40, y: 20),
            MD70Point(x: 80, y: 20),
            MD70Point(x: 100, y: 80),

            MD70Point(x: 120, y: 140),
            MD70Point(x: 160, y: 140),
            MD70Point(x: 180, y: 80),
        ]

        let bezier = decodeBezier(
            points: points,
            penWidth: 3,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: false,
            fillColor: .white,
            fillPresetIndex: 0
        )

        XCTAssertEqual(bezier.anchor, points.first)
        XCTAssertEqual(bezier.points, points)
        XCTAssertEqual(bezier.segments.count, 2)
        XCTAssertFalse(bezier.isClosed)

        let first = bezier.segments[0]

        XCTAssertEqual(first.start, points[0])
        XCTAssertEqual(first.control1, points[1])
        XCTAssertEqual(first.control2, points[2])
        XCTAssertEqual(first.end, points[3])

        let second = bezier.segments[1]

        XCTAssertEqual(second.start, points[3])
        XCTAssertEqual(second.control1, points[4])
        XCTAssertEqual(second.control2, points[5])
        XCTAssertEqual(second.end, points[6])

        try MD70TestSupport.assertStyle(
            bezier.style,
            penWidth: 3,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: false,
            fillColor: .white,
            fillPresetIndex: 0
        )
    }

    func testMovedPathPreservesRelativeGeometry() {
        let original = [
            MD70Point(x: 20, y: 80),
            MD70Point(x: 40, y: 20),
            MD70Point(x: 80, y: 20),
            MD70Point(x: 100, y: 80),
        ]

        let moved = original.map {
            MD70Point(
                x: $0.x - 3,
                y: $0.y + 36
            )
        }

        let bezier = decodeBezier(points: moved)

        XCTAssertEqual(bezier.points, moved)
        XCTAssertEqual(bezier.anchor, moved.first)
    }

    func testMovingSecondControlHandleChangesOnlyControl2() {
        let original = [
            MD70Point(x: 20, y: 80),
            MD70Point(x: 40, y: 20),
            MD70Point(x: 80, y: 20),
            MD70Point(x: 100, y: 80),
        ]

        var movedHandle = original
        movedHandle[2] = MD70Point(
            x: original[2].x,
            y: original[2].y - 25
        )

        let originalBezier = decodeBezier(
            points: original
        )

        let movedBezier = decodeBezier(
            points: movedHandle
        )

        let originalSegment =
            originalBezier.segments[0]

        let movedSegment =
            movedBezier.segments[0]

        XCTAssertEqual(
            movedSegment.start,
            originalSegment.start
        )

        XCTAssertEqual(
            movedSegment.control1,
            originalSegment.control1
        )

        XCTAssertNotEqual(
            movedSegment.control2,
            originalSegment.control2
        )

        XCTAssertEqual(
            movedSegment.end,
            originalSegment.end
        )

        XCTAssertGreaterThan(
            movedSegment.incomingHandle.length,
            originalSegment.incomingHandle.length
        )
    }

    func testClosedPathIsDerivedFromMatchingEndpoints() {
        let start = MD70Point(x: 50, y: 80)

        let points = [
            start,

            MD70Point(x: 80, y: 30),
            MD70Point(x: 130, y: 30),
            MD70Point(x: 150, y: 80),

            MD70Point(x: 130, y: 130),
            MD70Point(x: 80, y: 130),
            start,
        ]

        let bezier = decodeBezier(points: points)

        XCTAssertTrue(bezier.isClosed)
        XCTAssertEqual(bezier.segments.count, 2)
        XCTAssertEqual(
            bezier.segments.last?.end,
            start
        )
    }

    func testDecodesMultiSegmentPath() {
        var points = [
            MD70Point(x: 10, y: 100)
        ]

        for index in 0..<10 {
            let base = Double(index) * 30

            points.append(
                MD70Point(
                    x: 20 + base,
                    y: 40
                )
            )

            points.append(
                MD70Point(
                    x: 30 + base,
                    y: 160
                )
            )

            points.append(
                MD70Point(
                    x: 40 + base,
                    y: 100
                )
            )
        }

        let bezier = decodeBezier(points: points)

        XCTAssertEqual(bezier.points.count, 31)
        XCTAssertEqual(bezier.segments.count, 10)
    }

    func testHandleLengthAndClockwiseAngle() throws {
        let points = [
            MD70Point(x: 10, y: 10),
            MD70Point(x: 13, y: 14),
            MD70Point(x: 18, y: 10),
            MD70Point(x: 20, y: 10),
        ]

        let segment = try XCTUnwrap(
            decodeBezier(points: points)
                .segments.first
        )

        XCTAssertEqual(
            segment.outgoingHandle.length,
            5,
            accuracy: MD70TestSupport.accuracy
        )

        XCTAssertEqual(
            segment.outgoingHandle.angleDegrees,
            53.130102,
            accuracy: MD70TestSupport.accuracy
        )

        XCTAssertEqual(
            segment.incomingHandle.length,
            2,
            accuracy: MD70TestSupport.accuracy
        )

        XCTAssertEqual(
            segment.incomingHandle.angleDegrees,
            180,
            accuracy: MD70TestSupport.accuracy
        )
    }

    func testBoundsIncludeControlPoints() throws {
        let points = [
            MD70Point(x: 20, y: 80),
            MD70Point(x: -10, y: 15),
            MD70Point(x: 140, y: 160),
            MD70Point(x: 100, y: 80),
        ]

        let bounds = try XCTUnwrap(
            decodeBezier(points: points).bounds
        )

        XCTAssertEqual(bounds.left, -10)
        XCTAssertEqual(bounds.top, 15)
        XCTAssertEqual(bounds.right, 140)
        XCTAssertEqual(bounds.bottom, 160)
    }

    func testPreservesRawRecord() {
        let points = [
            MD70Point(x: 20, y: 80),
            MD70Point(x: 40, y: 20),
            MD70Point(x: 80, y: 20),
            MD70Point(x: 100, y: 80),
        ]

        let record = makeBezierRecord(
            points: points
        )

        let bezier = MD70BezierDecoder.decode(
            header: makeHeader(
                recordLength: record.count
            ),
            record: record
        )

        XCTAssertEqual(bezier.rawRecord, record)
    }

    func testTruncatedRecordProducesEmptyGeometryAndNilStyle() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let bezier = MD70BezierDecoder.decode(
            header: makeHeader(
                recordLength: record.count
            ),
            record: record
        )

        XCTAssertNil(bezier.anchor)
        XCTAssertTrue(bezier.points.isEmpty)
        XCTAssertTrue(bezier.segments.isEmpty)
        XCTAssertNil(bezier.bounds)
        XCTAssertFalse(bezier.isClosed)

        XCTAssertNil(bezier.penWidth)
        XCTAssertNil(bezier.strokeColor)
        XCTAssertNil(bezier.strokePresetIndex)
        XCTAssertFalse(bezier.isFillEnabled)
        XCTAssertNil(bezier.fillColor)
        XCTAssertNil(bezier.fillPresetIndex)

        XCTAssertEqual(bezier.rawRecord, record)
    }

    private func decodeBezier(
        points: [MD70Point],
        penWidth: Double = 1,
        strokeColor: MD70TestColor = .black,
        strokePresetIndex: UInt8 = 2,
        isFillEnabled: Bool = false,
        fillColor: MD70TestColor = .white,
        fillPresetIndex: UInt8 = 0
    ) -> MD70Bezier {
        let record = makeBezierRecord(
            points: points,
            penWidth: penWidth,
            strokeColor: strokeColor,
            strokePresetIndex: strokePresetIndex,
            isFillEnabled: isFillEnabled,
            fillColor: fillColor,
            fillPresetIndex: fillPresetIndex
        )

        return MD70BezierDecoder.decode(
            header: makeHeader(
                recordLength: record.count
            ),
            record: record
        )
    }

    private func makeBezierRecord(
        points: [MD70Point],
        penWidth: Double = 1,
        strokeColor: MD70TestColor = .black,
        strokePresetIndex: UInt8 = 2,
        isFillEnabled: Bool = false,
        fillColor: MD70TestColor = .white,
        fillPresetIndex: UInt8 = 0
    ) -> Data {
        let recordLength =
            Self.pointTableOffset +
            points.count * Self.pointStride

        var record = Data(
            repeating: 0,
            count: recordLength
        )

        if let anchor = points.first {
            MD70TestSupport.writeScaledFloat64BE(
                anchor.y,
                to: &record,
                at: Self.anchorYOffset
            )

            MD70TestSupport.writeScaledFloat64BE(
                anchor.x,
                to: &record,
                at: Self.anchorXOffset
            )
        }

        MD70TestSupport.writeStyle(
            to: &record,
            penWidth: penWidth,
            strokeColor: strokeColor,
            strokePresetIndex: strokePresetIndex,
            isFillEnabled: isFillEnabled,
            fillColor: fillColor,
            fillPresetIndex: fillPresetIndex
        )

        MD70TestSupport.writeUInt32BE(
            UInt32(points.count),
            to: &record,
            at: Self.pointCountOffset
        )

        for (index, point) in points.enumerated() {
            let base =
                Self.pointTableOffset +
                index * Self.pointStride

            MD70TestSupport.writeScaledFloat64BE(
                point.y,
                to: &record,
                at: base + Self.pointYOffset
            )

            MD70TestSupport.writeScaledFloat64BE(
                point.x,
                to: &record,
                at: base + Self.pointXOffset
            )

            if index % 3 == 0 {
                record[base + 0x1D] = 0x81
            }

            if index == 0 {
                record[base + 0x1E] = 0x01
            }
        }

        return record
    }

    private func makeHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode:
                MD70ObjectType.bezier.rawValue,
            type: .bezier,
            storedLength: UInt32(
                max(0, recordLength - 12)
            )
        )
    }
}
