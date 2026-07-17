import Foundation

/// A parsed MacDraft MD70-family document.
public struct MacDraftDocument: Sendable {
    /// The identifier stored at the beginning of the document, such as `MD7020`.
    public let formatIdentifier: String

    /// The embedded PDF payload, when one is present.
    public let embeddedPDF: EmbeddedPDF?

    /// Creates a document by reading a file from disk.
    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        try self.init(data: data)
    }

    /// Creates a document from in-memory bytes.
    public init(data: Data) throws {
        guard data.count >= 6 else {
            throw MacDraftError.fileTooSmall
        }

        let identifierData = data.prefix(6)
        guard let identifier = String(data: identifierData, encoding: .ascii),
              identifier.hasPrefix("MD70") else {
            throw MacDraftError.invalidFormatIdentifier
        }

        self.formatIdentifier = identifier
        self.embeddedPDF = PDFExtractor.extractFirstPDF(from: data)
    }
}
