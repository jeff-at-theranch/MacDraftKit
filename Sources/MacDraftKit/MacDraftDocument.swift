import Foundation

/// A parsed MacDraft MD70-family document.
public struct MacDraftDocument: Sendable {
    /// The parsed fixed header at the beginning of the document.
    public let header: MacDraftHeader

    /// The identifier stored at the beginning of the document, such as `MD7020`.
    public var formatIdentifier: String {
        header.formatIdentifier
    }

    /// The embedded PDF payload, when one is present.
    public let embeddedPDF: EmbeddedPDF?

    /// Creates a document by reading a file from disk.
    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        try self.init(data: data)
    }

    /// Creates a document from in-memory bytes.
    public init(data: Data) throws {
        self.header = try MacDraftHeader(data: data)
        self.embeddedPDF = PDFExtractor.extractFirstPDF(from: data)
    }
}
