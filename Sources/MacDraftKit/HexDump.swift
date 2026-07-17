import Foundation

/// Formats binary data as offset-addressed hexadecimal and ASCII rows.
public struct HexDump: Sendable {
    public let data: Data
    public let bytesPerLine: Int

    public init(data: Data, bytesPerLine: Int = 16) throws {
        guard bytesPerLine > 0 else {
            throw HexDumpError.invalidBytesPerLine(bytesPerLine)
        }

        self.data = data
        self.bytesPerLine = bytesPerLine
    }

    /// Returns formatted rows for a byte range.
    ///
    /// The final row may contain fewer than `bytesPerLine` bytes. A range that
    /// extends beyond the end of the data is truncated to the available bytes.
    public func lines(from offset: Int = 0, count: Int? = nil) throws -> [String] {
        guard (0...data.count).contains(offset) else {
            throw HexDumpError.invalidOffset(offset, dataCount: data.count)
        }

        let requestedCount = count ?? (data.count - offset)
        guard requestedCount >= 0 else {
            throw HexDumpError.negativeCount(requestedCount)
        }

        let end = min(data.count, offset + requestedCount)
        guard offset < end else {
            return []
        }

        let addressWidth = max(8, String(max(data.count - 1, 0), radix: 16).count)
        var result: [String] = []
        var lineOffset = offset

        while lineOffset < end {
            let lineEnd = min(lineOffset + bytesPerLine, end)
            let bytes = data[lineOffset..<lineEnd]

            let address = String(lineOffset, radix: 16, uppercase: true)
                .leftPadded(to: addressWidth, with: "0")

            let hexadecimal = bytes
                .map { String(format: "%02X", $0) }
                .joined(separator: " ")
                .rightPadded(to: (bytesPerLine * 3) - 1)

            let ascii = bytes.map { byte -> Character in
                guard (0x20...0x7E).contains(byte) else {
                    return "."
                }
                return Character(UnicodeScalar(byte))
            }

            result.append("\(address)  \(hexadecimal)  |\(String(ascii))|")
            lineOffset = lineEnd
        }

        return result
    }

    public func string(from offset: Int = 0, count: Int? = nil) throws -> String {
        try lines(from: offset, count: count).joined(separator: "\n")
    }
}

public enum HexDumpError: Error, Equatable, Sendable {
    case invalidBytesPerLine(Int)
    case invalidOffset(Int, dataCount: Int)
    case negativeCount(Int)
}

extension HexDumpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidBytesPerLine(value):
            return "Bytes per line must be greater than zero: \(value)."
        case let .invalidOffset(offset, dataCount):
            return "Offset \(offset) is outside the valid range 0...\(dataCount)."
        case let .negativeCount(count):
            return "A hex-dump byte count cannot be negative: \(count)."
        }
    }
}

private extension String {
    func leftPadded(to length: Int, with character: Character) -> String {
        guard count < length else { return self }
        return String(repeating: String(character), count: length - count) + self
    }

    func rightPadded(to length: Int) -> String {
        guard count < length else { return self }
        return self + String(repeating: " ", count: length - count)
    }
}
