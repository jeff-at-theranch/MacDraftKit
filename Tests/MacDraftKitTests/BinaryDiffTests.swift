import XCTest
@testable import MacDraftKit

final class BinaryDiffTests: XCTestCase {
    func testIdenticalDataProducesOneEqualRegion() {
        let data = Data([1, 2, 3, 4])
        let diff = BinaryDiff(left: data, right: data, anchorLength: 2)
        XCTAssertEqual(diff.regions, [
            .init(kind: .equal, leftRange: 0..<4, rightRange: 0..<4)
        ])
    }

    func testInsertionIsDetected() {
        let left = Data(Array("abcdefghijklmnopQRSTUV".utf8))
        let right = Data(Array("abcdefghijklmnopINSERTQRSTUV".utf8))
        let diff = BinaryDiff(left: left, right: right, anchorLength: 4)
        XCTAssertTrue(diff.regions.contains {
            $0.kind == .inserted && $0.leftRange.isEmpty && $0.rightRange.count == 6
        })
    }

    func testReplacementIsDetected() {
        let left = Data(Array("abcdefghijklmnopLEFTqrstuvwxyz".utf8))
        let right = Data(Array("abcdefghijklmnopRIGHTqrstuvwxyz".utf8))
        let diff = BinaryDiff(left: left, right: right, anchorLength: 6)
        XCTAssertTrue(diff.regions.contains {
            $0.kind == .replaced && !$0.leftRange.isEmpty && !$0.rightRange.isEmpty
        })
    }
}
