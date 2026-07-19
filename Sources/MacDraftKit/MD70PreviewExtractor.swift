import Foundation

public enum MD70PreviewExtractor {
    public enum ExtractionError:
        Error,
        LocalizedError
    {
        case pdfHeaderNotFound
        case pdfEndMarkerNotFound
        case invalidPDFRange

        public var errorDescription: String? {
            switch self {
            case .pdfHeaderNotFound:
                return "No embedded PDF header was found."

            case .pdfEndMarkerNotFound:
                return "The embedded PDF has no end marker."

            case .invalidPDFRange:
                return "The embedded PDF occupies an invalid byte range."
            }
        }
    }

    private static let pdfHeader = Data(
        "%PDF-".utf8
    )

    private static let pdfEndMarker = Data(
        "%%EOF".utf8
    )

    public static func embeddedPDF(
        from fileURL: URL
    ) throws -> Data {
        let documentData = try Data(
            contentsOf: fileURL,
            options: .mappedIfSafe
        )

        return try embeddedPDF(
            from: documentData
        )
    }

    public static func embeddedPDF(
        from documentData: Data
    ) throws -> Data {
        guard let headerRange = documentData.range(
            of: pdfHeader
        ) else {
            throw ExtractionError.pdfHeaderNotFound
        }

        guard let endMarkerRange = documentData.range(
            of: pdfEndMarker,
            options: .backwards,
            in: headerRange.lowerBound..<documentData.endIndex
        ) else {
            throw ExtractionError.pdfEndMarkerNotFound
        }

        let pdfStart = headerRange.lowerBound
        var pdfEnd = endMarkerRange.upperBound

        // Preserve a trailing CR/LF after %%EOF when present.
        while pdfEnd < documentData.endIndex {
            let byte = documentData[pdfEnd]

            guard byte == 0x0A || byte == 0x0D else {
                break
            }

            pdfEnd = documentData.index(
                after: pdfEnd
            )
        }

        guard pdfStart < pdfEnd else {
            throw ExtractionError.invalidPDFRange
        }

        return documentData.subdata(
            in: pdfStart..<pdfEnd
        )
    }
}

