import Foundation

struct MD70BinaryReader {
    let data: Data

    func uint8(at offset: Int) -> UInt8? {
        guard contains(offset: offset, count: 1) else { return nil }
        return data[offset]
    }

    func uint32LE(at offset: Int) -> UInt32? {
        guard contains(offset: offset, count: 4) else { return nil }
        return UInt32(data[offset])
            | (UInt32(data[offset + 1]) << 8)
            | (UInt32(data[offset + 2]) << 16)
            | (UInt32(data[offset + 3]) << 24)
    }

    func uint32BE(at offset: Int) -> UInt32? {
        guard contains(offset: offset, count: 4) else { return nil }
        return (UInt32(data[offset]) << 24)
            | (UInt32(data[offset + 1]) << 16)
            | (UInt32(data[offset + 2]) << 8)
            | UInt32(data[offset + 3])
    }

    func float64BE(at offset: Int) -> Double? {
        guard contains(offset: offset, count: 8) else { return nil }

        var bits: UInt64 = 0
        for index in 0..<8 {
            bits = (bits << 8) | UInt64(data[offset + index])
        }
        return Double(bitPattern: bits)
    }

    func slice(at offset: Int, count: Int) -> Data? {
        guard contains(offset: offset, count: count) else { return nil }
        return data.subdata(in: offset..<(offset + count))
    }

    func contains(offset: Int, count: Int) -> Bool {
        guard offset >= 0, count >= 0 else { return false }
        let (end, overflow) = offset.addingReportingOverflow(count)
        return !overflow && end <= data.count
    }
}
