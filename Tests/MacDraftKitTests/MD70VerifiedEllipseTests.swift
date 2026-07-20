import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedEllipseTests: XCTestCase {
    func testDecodesGeometryAndStyle() throws {
        var record = Data(repeating: 0, count: 0xE0)
        MD70TestSupport.writeScaledFloat64BE(40, to: &record, at: 0x09)
        MD70TestSupport.writeScaledFloat64BE(50, to: &record, at: 0x11)
        MD70TestSupport.writeScaledFloat64BE(100, to: &record, at: 0xCB)
        MD70TestSupport.writeScaledFloat64BE(150, to: &record, at: 0xD3)
        MD70TestSupport.writeStyle(
            to: &record,
            penWidth: 2,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )

        let ellipse = MD70EllipseDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertEqual(ellipse.anchor, MD70Point(x: 50, y: 40))
        let bounds = try XCTUnwrap(ellipse.bounds)
        XCTAssertEqual(bounds.left, 50)
        XCTAssertEqual(bounds.top, 40)
        XCTAssertEqual(bounds.right, 150)
        XCTAssertEqual(bounds.bottom, 100)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 60)

        try MD70TestSupport.assertStyle(
            ellipse.style,
            penWidth: 2,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )
        XCTAssertEqual(ellipse.rawRecord, record)
    }

    func testTruncatedRecordProducesNilValues() {
        let record = Data(repeating: 0, count: 8)
        let ellipse = MD70EllipseDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertNil(ellipse.anchor)
        XCTAssertNil(ellipse.bounds)
        XCTAssertNil(ellipse.penWidth)
        XCTAssertNil(ellipse.strokeColor)
        XCTAssertFalse(ellipse.isFillEnabled)
        XCTAssertNil(ellipse.fillColor)
    }

    private func makeHeader(_ length: Int) -> MD70ObjectHeader {
        MD70ObjectHeader(offset: 0, rawTypeCode: 0x18, type: .ellipse, storedLength: UInt32(max(0, length - 12)))
    }
}
