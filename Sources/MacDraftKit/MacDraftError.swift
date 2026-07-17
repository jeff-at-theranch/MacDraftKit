import Foundation

/// Errors produced while reading MacDraft documents.
public enum MacDraftError: Error, LocalizedError, Equatable, Sendable {
    case fileTooSmall
    case invalidFormatIdentifier
    case embeddedPDFNotFound

    public var errorDescription: String? {
        switch self {
        case .fileTooSmall:
            return "The file is too small to be a MacDraft document."
        case .invalidFormatIdentifier:
            return "The file does not contain a recognized MD70 format identifier."
        case .embeddedPDFNotFound:
            return "The document does not contain an embedded PDF."
        }
    }
}
