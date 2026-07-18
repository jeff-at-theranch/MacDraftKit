import Foundation

public enum BinaryRangeDumpError: Error, Equatable {
    case invalidRange
    case rangeOutsideData
}

public struct BinaryRangeDump: Sendable, Equatable {
    public let range: Range<Int>
    public let bytesPerLine: Int

    public init(data: Data, range: Range<Int>, bytesPerLine: Int = 16) throws {
        guard bytesPerLine > 0, range.lowerBound >= 0, range.lowerBound <= range.upperBound else {
            throw BinaryRangeDumpError.invalidRange
        }
        guard range.upperBound <= data.count else {
            throw BinaryRangeDumpError.rangeOutsideData
        }
        self.range = range
        self.bytesPerLine = bytesPerLine
    }

    public func render(data: Data) -> String {
        guard !range.isEmpty else { return "" }
        var lines: [String] = []
        var offset = range.lowerBound
        while offset < range.upperBound {
            let end = min(offset + bytesPerLine, range.upperBound)
            let bytes = Array(data[offset..<end])
            let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
            let paddedHex = hex.padding(toLength: bytesPerLine * 3 - 1, withPad: " ", startingAt: 0)
            let ascii = String(bytes.map { (0x20...0x7E).contains($0) ? Character(UnicodeScalar($0)) : "." })
            lines.append(String(format: "%08X  %@  |%@|", offset, paddedHex, ascii))
            offset = end
        }
        return lines.joined(separator: "\n")
    }
}
