import Foundation
import XCTest
@testable import MacDraftKit

final class DocumentProbeTests: XCTestCase {
    func testReportsFileSize() throws {
        XCTAssertEqual(
            try DocumentProbe(data: Data([1, 2, 3])).run().fileSize,
            3
        )
    }

    func testFindsKnownSignaturesAtExactOffsets() throws {
        var bytes = Array(repeating: UInt8(0), count: 32)
        bytes.replaceSubrange(3..<8, with: Array("%PDF-".utf8))
        bytes.replaceSubrange(20..<24, with: [0x50, 0x4B, 0x03, 0x04])

        let report = try DocumentProbe(data: Data(bytes)).run()

        XCTAssertTrue(report.signatures.contains(.init(kind: .pdf, offset: 3)))
        XCTAssertTrue(report.signatures.contains(.init(kind: .zip, offset: 20)))
    }

    func testFindsMultipleOccurrencesOfSameSignature() throws {
        let report = try DocumentProbe(data: Data("%PDF-a\0%PDF-b".utf8)).run()

        XCTAssertEqual(
            report.signatures.filter { $0.kind == .pdf }.map(\.offset),
            [0, 7]
        )
    }

    func testFindsPrintableASCIIStrings() throws {
        let data = Data(
            [0x00] + Array("MD7001".utf8) + [0x00] + Array("Layer 1".utf8)
        )

        XCTAssertEqual(
            try DocumentProbe(data: data).run().asciiStrings,
            [
                .init(offset: 1, value: "MD7001"),
                .init(offset: 8, value: "Layer 1")
            ]
        )
    }

    func testIgnoresShortASCIIStrings() throws {
        let report = try DocumentProbe(
            data: Data("abc\0abcd".utf8),
            minimumASCIIStringLength: 4
        ).run()

        XCTAssertEqual(report.asciiStrings, [.init(offset: 4, value: "abcd")])
    }

    func testCapturesASCIIStringAtEndOfData() throws {
        XCTAssertEqual(
            try DocumentProbe(data: Data("ending".utf8)).run().asciiStrings,
            [.init(offset: 0, value: "ending")]
        )
    }

    func testSortsSignatureMatchesByOffset() throws {
        let data = Data([0x50, 0x4B, 0x03, 0x04, 0x00] + Array("%PDF-".utf8))

        XCTAssertEqual(
            try DocumentProbe(data: data).run().signatures.map(\.offset),
            [0, 5]
        )
    }

    func testRejectsInvalidMinimumStringLength() {
        XCTAssertThrowsError(
            try DocumentProbe(data: Data(), minimumASCIIStringLength: 0)
        ) { error in
            XCTAssertEqual(
                error as? DocumentProbeError,
                .invalidMinimumASCIIStringLength(0)
            )
        }
    }
}
