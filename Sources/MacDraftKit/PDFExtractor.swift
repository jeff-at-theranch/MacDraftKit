import Foundation

enum PDFExtractor {
    private static let header = Data("%PDF-".utf8)
    private static let endMarker = Data("%%EOF".utf8)

    static func extractFirstPDF(from data: Data) -> EmbeddedPDF? {
        guard let start = data.range(of: header)?.lowerBound else {
            return nil
        }

        guard let endMarkerRange = data.range(
            of: endMarker,
            options: [],
            in: start..<data.endIndex
        ) else {
            return nil
        }

        var end = endMarkerRange.upperBound
        while end < data.endIndex, data[end] == 0x0A || data[end] == 0x0D {
            end += 1
        }

        return EmbeddedPDF(
            offset: data.distance(from: data.startIndex, to: start),
            data: data.subdata(in: start..<end)
        )
    }
}
