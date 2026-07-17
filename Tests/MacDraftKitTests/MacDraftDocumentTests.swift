import Foundation
import XCTest
@testable import MacDraftKit

final class MacDraftDocumentTests: XCTestCase {
    func testParsesIdentifierAndEmbeddedPDF() throws {
        let pdf = Data("%PDF-1.4\n1 0 obj\n<<>>\nendobj\n%%EOF\n".utf8)
        var bytes = Data("MD7020".utf8)
        bytes.append(Data(repeating: 0, count: 8))
        bytes.append(pdf)
        bytes.append(Data(repeating: 0, count: 4))

        let document = try MacDraftDocument(data: bytes)

        XCTAssertEqual(document.formatIdentifier, "MD7020")
        XCTAssertEqual(document.embeddedPDF?.offset, 14)
        XCTAssertEqual(document.embeddedPDF?.data, pdf)
    }

    func testRejectsUnknownIdentifier() {
        XCTAssertThrowsError(try MacDraftDocument(data: Data("NOTMD7".utf8))) { error in
            XCTAssertEqual(error as? MacDraftError, .invalidFormatIdentifier)
        }
    }

    func testAcceptsDocumentWithoutEmbeddedPDF() throws {
        let document = try MacDraftDocument(data: Data("MD7020payload".utf8))
        XCTAssertNil(document.embeddedPDF)
    }
}
