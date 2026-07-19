import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedTextTests: XCTestCase {
    func testTextObjectExtractsEmbeddedRTF() {
        let prefix = Data(repeating: 0, count: 0x150)
        let expectedRTF = Data("{\\rtf1\\ansi Test}".utf8)
        let record = prefix + expectedRTF

        let header = MD70ObjectHeader(
            offset: 0x511B,
            rawTypeCode: MD70ObjectType.text.rawValue,
            type: .text,
            storedLength: UInt32(record.count - 12)
        )

        let text = MD70TextDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertFalse(text.rtfData.isEmpty)
        XCTAssertEqual(text.rtfData, expectedRTF)
        XCTAssertTrue(
            text.rtfData.starts(with: Data("{\\rtf".utf8))
        )
        XCTAssertEqual(text.rawRecord, record)
    }

    func testTextObjectWithoutRTFReturnsEmptyData() {
        let record = Data(repeating: 0, count: 512)

        let header = MD70ObjectHeader(
            offset: 0,
            rawTypeCode: MD70ObjectType.text.rawValue,
            type: .text,
            storedLength: UInt32(record.count - 12)
        )

        let text = MD70TextDecoder.decode(
            header: header,
            record: record
        )

        XCTAssertTrue(text.rtfData.isEmpty)
        XCTAssertEqual(text.rawRecord, record)
    }
}
