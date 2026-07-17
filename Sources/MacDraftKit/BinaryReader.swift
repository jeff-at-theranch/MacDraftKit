import Foundation

/// Reads primitive values from an in-memory binary buffer while tracking position
/// and validating every access.
public struct BinaryReader {
    public enum ByteOrder: Sendable {
        case littleEndian
        case bigEndian
    }

    public let data: Data
    public private(set) var offset: Int

    public var remainingCount: Int {
        data.count - offset
    }

    public var isAtEnd: Bool {
        offset == data.count
    }

    public init(data: Data, offset: Int = 0) throws {
        guard (0...data.count).contains(offset) else {
            throw BinaryReaderError.invalidOffset(offset, dataCount: data.count)
        }

        self.data = data
        self.offset = offset
    }

    public mutating func seek(to newOffset: Int) throws {
        guard (0...data.count).contains(newOffset) else {
            throw BinaryReaderError.invalidOffset(newOffset, dataCount: data.count)
        }

        offset = newOffset
    }

    public mutating func skip(_ count: Int) throws {
        guard count >= 0 else {
            throw BinaryReaderError.negativeCount(count)
        }

        try seek(to: offset + count)
    }

    public mutating func readData(count: Int) throws -> Data {
        guard count >= 0 else {
            throw BinaryReaderError.negativeCount(count)
        }

        guard count <= remainingCount else {
            throw BinaryReaderError.outOfBounds(
                offset: offset,
                requestedCount: count,
                remainingCount: remainingCount
            )
        }

        let start = offset
        offset += count
        return data.subdata(in: start..<offset)
    }

    public mutating func readUInt8() throws -> UInt8 {
        let bytes = try readData(count: 1)
        return bytes[bytes.startIndex]
    }

    public mutating func readInteger<T: FixedWidthInteger>(
        _ type: T.Type = T.self,
        byteOrder: ByteOrder = .littleEndian
    ) throws -> T {
        let byteCount = MemoryLayout<T>.size
        let bytes = try readData(count: byteCount)

        var value: T = 0

        switch byteOrder {
        case .littleEndian:
            for (index, byte) in bytes.enumerated() {
                value |= T(truncatingIfNeeded: byte) << (index * 8)
            }

        case .bigEndian:
            for byte in bytes {
                value = (value << 8) | T(truncatingIfNeeded: byte)
            }
        }

        return value
    }
}

public enum BinaryReaderError: Error, Equatable, Sendable {
    case invalidOffset(Int, dataCount: Int)
    case negativeCount(Int)
    case outOfBounds(offset: Int, requestedCount: Int, remainingCount: Int)
}

extension BinaryReaderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidOffset(offset, dataCount):
            return "Offset \(offset) is outside the valid range 0...\(dataCount)."

        case let .negativeCount(count):
            return "A binary read or skip count cannot be negative: \(count)."

        case let .outOfBounds(offset, requestedCount, remainingCount):
            return """
            Cannot read \(requestedCount) byte(s) at offset \(offset); \
            only \(remainingCount) byte(s) remain.
            """
        }
    }
}
