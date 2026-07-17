import Foundation

/// An embedded PDF discovered inside a MacDraft document.
public struct EmbeddedPDF: Sendable, Equatable {
    /// The byte offset where the PDF begins in the original document.
    public let offset: Int

    /// The complete PDF bytes.
    public let data: Data

    /// The number of bytes in the PDF payload.
    public var length: Int { data.count }

    public init(offset: Int, data: Data) {
        self.offset = offset
        self.data = data
    }

    /// Writes the PDF payload to disk.
    public func write(to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
}
