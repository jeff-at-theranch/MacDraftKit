import Foundation

/// The fixed six-byte identifier at the beginning of an MD70-family document.
public struct MacDraftHeader: Equatable, Sendable {
    /// Number of bytes occupied by the currently understood header identifier.
    public static let byteCount = 6

    /// The MD70 format family marker.
    public let family: String

    /// The two-character revision encoded after the family marker.
    ///
    /// For example, the identifier `MD7020` has revision `20`.
    public let revision: String

    /// The complete six-character identifier as stored in the file.
    public var formatIdentifier: String {
        family + revision
    }

    /// Parses the fixed identifier at the start of a MacDraft document.
    public init(data: Data) throws {
        guard data.count >= Self.byteCount else {
            throw MacDraftError.fileTooSmall
        }

        let identifierBytes = data.prefix(Self.byteCount)
        guard let identifier = String(data: identifierBytes, encoding: .ascii) else {
            throw MacDraftError.invalidFormatIdentifier
        }

        let family = String(identifier.prefix(4))
        let revision = String(identifier.suffix(2))

        guard family == "MD70",
              revision.count == 2,
              revision.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            throw MacDraftError.invalidFormatIdentifier
        }

        self.family = family
        self.revision = revision
    }
}
