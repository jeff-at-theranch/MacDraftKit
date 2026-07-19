import Foundation

private extension Data {
    func firstOccurrence(of pattern: Data) -> Int? {
        guard !pattern.isEmpty,
              pattern.count <= count else {
            return nil
        }

        let last = count - pattern.count

        for offset in 0...last {
            if self[offset..<(offset + pattern.count)] == pattern[...] {
                return offset
            }
        }

        return nil
    }
}

enum MD70TextDecoder {
    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Text {
        let magic = Data("{\\rtf".utf8)

        let rtfData: Data
        if let offset = record.firstOccurrence(of: magic) {
            rtfData = Data(record[offset...])
        } else {
            rtfData = Data()
        }

        return MD70Text(
            header: header,
            rawRecord: record,
            rtfData: rtfData
        )
    }
}
