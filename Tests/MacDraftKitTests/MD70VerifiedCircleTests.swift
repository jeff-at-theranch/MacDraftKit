import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedCircleTests: XCTestCase {
    func testDecodesGeometryAndStyle() throws {
        var record = Data(repeating: 0, count: 0x123)
        MD70TestSupport.writeScaledFloat64BE(60, to: &record, at: 0x09)
        MD70TestSupport.writeScaledFloat64BE(50, to: &record, at: 0x11)
        MD70TestSupport.writeScaledFloat64BE(30, to: &record, at: 0xCB)
        MD70TestSupport.writeStyle(
            to: &record,
            penWidth: 3,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )

        let circle = MD70CircleDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertEqual(circle.anchor, MD70Point(x: 50, y: 60))
        XCTAssertEqual(try XCTUnwrap(circle.radius), 30, accuracy: MD70TestSupport.accuracy)
        XCTAssertEqual(try XCTUnwrap(circle.diameter), 60, accuracy: MD70TestSupport.accuracy)

        let center = try XCTUnwrap(circle.center)
        let component = 30 / sqrt(2.0)
        XCTAssertEqual(center.x, 50 + component, accuracy: MD70TestSupport.accuracy)
        XCTAssertEqual(center.y, 60 + component, accuracy: MD70TestSupport.accuracy)

        try MD70TestSupport.assertStyle(
            circle.style,
            penWidth: 3,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )
        XCTAssertEqual(circle.rawRecord, record)
    }

    func testTruncatedRecordProducesNilValues() {
        let record = Data(repeating: 0, count: 8)
        let circle = MD70CircleDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertNil(circle.anchor)
        XCTAssertNil(circle.center)
        XCTAssertNil(circle.radius)
        XCTAssertNil(circle.penWidth)
        XCTAssertNil(circle.strokeColor)
        XCTAssertFalse(circle.isFillEnabled)
        XCTAssertNil(circle.fillColor)
    }

    private func makeHeader(_ length: Int) -> MD70ObjectHeader {
        MD70ObjectHeader(offset: 0, rawTypeCode: 0x14, type: .circle, storedLength: UInt32(max(0, length - 12)))
    }
}
