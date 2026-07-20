import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedRectangleTests: XCTestCase {
    func testDecodesGeometryAndStyle() throws {
        var record = Data(repeating: 0, count: 0x15A)
        MD70TestSupport.writeScaledFloat64BE(50, to: &record, at: 0x09)
        MD70TestSupport.writeScaledFloat64BE(60, to: &record, at: 0x11)
        MD70TestSupport.writeScaledFloat64BE(160, to: &record, at: 0xEF)
        MD70TestSupport.writeScaledFloat64BE(110, to: &record, at: 0x107)
        MD70TestSupport.writeStyle(
            to: &record,
            penWidth: 2.5,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )

        let rectangle = MD70RectangleDecoder.decode(
            header: makeHeader(record.count),
            record: record
        )

        XCTAssertEqual(rectangle.anchor, MD70Point(x: 60, y: 50))
        let bounds = try XCTUnwrap(rectangle.bounds)
        XCTAssertEqual(bounds.left, 60)
        XCTAssertEqual(bounds.top, 50)
        XCTAssertEqual(bounds.right, 160)
        XCTAssertEqual(bounds.bottom, 110)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 60)

        try MD70TestSupport.assertStyle(
            rectangle.style,
            penWidth: 2.5,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )
        XCTAssertEqual(rectangle.rawRecord, record)
    }

    func testTruncatedRecordProducesNilValues() {
        let record = Data(repeating: 0, count: 8)
        let rectangle = MD70RectangleDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertNil(rectangle.anchor)
        XCTAssertNil(rectangle.bounds)
        XCTAssertNil(rectangle.penWidth)
        XCTAssertNil(rectangle.strokeColor)
        XCTAssertFalse(rectangle.isFillEnabled)
        XCTAssertNil(rectangle.fillColor)
    }

    private func makeHeader(_ length: Int) -> MD70ObjectHeader {
        MD70ObjectHeader(offset: 0, rawTypeCode: 0x0A, type: .rectangle, storedLength: UInt32(max(0, length - 12)))
    }
}
