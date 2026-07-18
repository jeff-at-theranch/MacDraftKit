import Foundation

/// Performs conservative, assumption-free inspection of an unknown binary file.
///
/// The probe reports directly observable facts: known byte signatures and
/// printable ASCII runs. It does not interpret undocumented MacDraft fields.
public struct DocumentProbe: Sendable {
    public struct SignatureMatch: Equatable, Sendable {
        public let kind: SignatureKind
        public let offset: Int

        public init(kind: SignatureKind, offset: Int) {
            self.kind = kind
            self.offset = offset
        }
    }

    public enum SignatureKind: String, CaseIterable, Sendable {
        case pdf = "PDF"
        case png = "PNG"
        case jpeg = "JPEG"
        case zip = "ZIP"
        case gzip = "GZIP"
        case tiffLittleEndian = "TIFF (little-endian)"
        case tiffBigEndian = "TIFF (big-endian)"

        fileprivate var bytes: [UInt8] {
            switch self {
            case .pdf: return Array("%PDF-".utf8)
            case .png: return [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
            case .jpeg: return [0xFF, 0xD8, 0xFF]
            case .zip: return [0x50, 0x4B, 0x03, 0x04]
            case .gzip: return [0x1F, 0x8B]
            case .tiffLittleEndian: return [0x49, 0x49, 0x2A, 0x00]
            case .tiffBigEndian: return [0x4D, 0x4D, 0x00, 0x2A]
            }
        }
    }

    public struct ASCIIString: Equatable, Sendable {
        public let offset: Int
        public let value: String

        public init(offset: Int, value: String) {
            self.offset = offset
            self.value = value
        }
    }

    public struct Report: Equatable, Sendable {
        public let fileSize: Int
        public let signatures: [SignatureMatch]
        public let asciiStrings: [ASCIIString]

        public init(
            fileSize: Int,
            signatures: [SignatureMatch],
            asciiStrings: [ASCIIString]
        ) {
            self.fileSize = fileSize
            self.signatures = signatures
            self.asciiStrings = asciiStrings
        }
    }

    public let data: Data
    public let minimumASCIIStringLength: Int

    public init(data: Data, minimumASCIIStringLength: Int = 4) throws {
        guard minimumASCIIStringLength > 0 else {
            throw DocumentProbeError.invalidMinimumASCIIStringLength(
                minimumASCIIStringLength
            )
        }

        self.data = data
        self.minimumASCIIStringLength = minimumASCIIStringLength
    }

    public func run() -> Report {
        Report(
            fileSize: data.count,
            signatures: findSignatures(),
            asciiStrings: findASCIIStrings()
        )
    }

    private func findSignatures() -> [SignatureMatch] {
        var matches: [SignatureMatch] = []

        for kind in SignatureKind.allCases {
            let signature = kind.bytes
            guard signature.count <= data.count else { continue }

            let finalStart = data.count - signature.count
            for offset in 0...finalStart {
                if data[offset..<(offset + signature.count)].elementsEqual(signature) {
                    matches.append(SignatureMatch(kind: kind, offset: offset))
                }
            }
        }

        return matches.sorted {
            if $0.offset == $1.offset {
                return $0.kind.rawValue < $1.kind.rawValue
            }
            return $0.offset < $1.offset
        }
    }

    private func findASCIIStrings() -> [ASCIIString] {
        var strings: [ASCIIString] = []
        var start: Int?
        var bytes: [UInt8] = []

        func finishRun() {
            defer {
                start = nil
                bytes.removeAll(keepingCapacity: true)
            }

            guard
                let runStart = start,
                bytes.count >= minimumASCIIStringLength,
                let value = String(bytes: bytes, encoding: .ascii)
            else {
                return
            }

            strings.append(ASCIIString(offset: runStart, value: value))
        }

        for (offset, byte) in data.enumerated() {
            if (0x20...0x7E).contains(byte) {
                if start == nil { start = offset }
                bytes.append(byte)
            } else {
                finishRun()
            }
        }

        finishRun()
        return strings
    }
}

public enum DocumentProbeError: Error, Equatable, Sendable {
    case invalidMinimumASCIIStringLength(Int)
}

extension DocumentProbeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidMinimumASCIIStringLength(length):
            return "Minimum ASCII string length must be greater than zero: \(length)."
        }
    }
}
