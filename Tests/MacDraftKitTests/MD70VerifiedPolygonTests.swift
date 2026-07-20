import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedPolygonTests: XCTestCase {
    func testDecodesVerticesBoundsAndStyle() throws {
        let vertices = [
            MD70Point(x: 50, y: 40),
            MD70Point(x: 120, y: 40),
            MD70Point(x: 140, y: 90),
            MD70Point(x: 80, y: 130),
            MD70Point(x: 30, y: 90),
        ]
        let record = makeRecord(vertices: vertices)
        let polygon = MD70PolygonDecoder.decode(header: makeHeader(record.count), record: record)

        XCTAssertEqual(polygon.vertices, vertices)
        XCTAssertEqual(polygon.anchor, vertices.last)
        XCTAssertEqual(polygon.shapeName, "Pentagon")
        let bounds = try XCTUnwrap(polygon.bounds)
        XCTAssertEqual(bounds.left, 30)
        XCTAssertEqual(bounds.top, 40)
        XCTAssertEqual(bounds.right, 140)
        XCTAssertEqual(bounds.bottom, 130)

        try MD70TestSupport.assertStyle(
            polygon.style,
            penWidth: 2,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )
        XCTAssertEqual(polygon.rawRecord, record)
    }

    func testShapeNames() {
        let names = [3: "Triangle", 4: "Quadrilateral", 5: "Pentagon", 6: "Hexagon", 7: "Heptagon", 8: "Octagon", 9: "Nonagon", 10: "Decagon", 11: "Hendecagon", 12: "Dodecagon"]
        for count in 3...12 {
            let vertices = (0..<count).map { index -> MD70Point in
                let angle = Double(index) * 2 * .pi / Double(count)
                return MD70Point(x: 100 + cos(angle) * 40, y: 100 + sin(angle) * 40)
            }
            let record = makeRecord(vertices: vertices)
            let polygon = MD70PolygonDecoder.decode(header: makeHeader(record.count), record: record)
            XCTAssertEqual(polygon.shapeName, names[count])
        }
    }

    func testTruncatedRecordProducesEmptyValues() {
        let record = Data(repeating: 0, count: 8)
        let polygon = MD70PolygonDecoder.decode(header: makeHeader(record.count), record: record)
        XCTAssertNil(polygon.anchor)
        XCTAssertTrue(polygon.vertices.isEmpty)
        XCTAssertNil(polygon.bounds)
        XCTAssertNil(polygon.penWidth)
        XCTAssertNil(polygon.strokeColor)
        XCTAssertFalse(polygon.isFillEnabled)
        XCTAssertNil(polygon.fillColor)
    }

    private func makeRecord(vertices: [MD70Point]) -> Data {
        let tableOffset = 0xD0
        let stride = 0x20
        var record = Data(repeating: 0, count: tableOffset + vertices.count * stride)

        if let anchor = vertices.last {
            MD70TestSupport.writeScaledFloat64BE(anchor.y, to: &record, at: 0x09)
            MD70TestSupport.writeScaledFloat64BE(anchor.x, to: &record, at: 0x11)
        }

        MD70TestSupport.writeStyle(
            to: &record,
            penWidth: 2,
            strokeColor: .macDraftRed,
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: .black,
            fillPresetIndex: 2
        )
        MD70TestSupport.writeUInt32BE(UInt32(vertices.count), to: &record, at: 0xCC)

        for (index, vertex) in vertices.enumerated() {
            let base = tableOffset + index * stride
            MD70TestSupport.writeScaledFloat64BE(vertex.y, to: &record, at: base)
            MD70TestSupport.writeScaledFloat64BE(vertex.x, to: &record, at: base + 8)
            record[base + 0x1D] = 0x81
            if index == vertices.count - 1 { record[base + 0x1E] = 0x01 }
        }
        return record
    }

    private func makeHeader(_ length: Int) -> MD70ObjectHeader {
        MD70ObjectHeader(offset: 0, rawTypeCode: 0x04, type: .polygon, storedLength: UInt32(max(0, length - 12)))
    }
}
