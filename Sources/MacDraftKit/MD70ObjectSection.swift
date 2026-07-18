import Foundation

/// The portion of an MD70 document that contains drawing objects.
///
/// Only fields confirmed through controlled binary comparisons are exposed.
/// The boundaries of subsequent object records are not yet known, so this
/// type currently decodes only the first object's confirmed geometry fields.
public struct MD70ObjectSection: Sendable, Equatable {
    public static let objectCountOffset = 0x5117
    public static let firstObjectOffset = 0x511B

    public let declaredObjectCount: UInt32
    public let firstObject: MD70CandidateObjectRecord?

    static func parse(from data: Data) -> MD70ObjectSection? {
        guard let count = data.md70UInt32LE(at: objectCountOffset) else {
            return nil
        }

        guard count > 0 else {
            return MD70ObjectSection(declaredObjectCount: count, firstObject: nil)
        }

        return MD70ObjectSection(
            declaredObjectCount: count,
            firstObject: MD70CandidateObjectRecord.parseFirst(from: data)
        )
    }
}

/// Confirmed fields from the first MD70 object record.
///
/// The object type itself has not yet been identified. The geometry fields
/// below have been verified with controlled circle and ellipse samples.
public struct MD70CandidateObjectRecord: Sendable, Equatable {
    public let offset: Int
    public let centerX: Double
    public let centerY: Double
    public let radiusX: Double
    public let radiusY: Double
    public let penWidth: Double

    public var width: Double { radiusX * 2 }
    public var height: Double { radiusY * 2 }

    private static let centerYOffset = 0x09
    private static let centerXOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let radiusYOffset = 0xEB
    private static let radiusXOffset = 0xEF

    static func parseFirst(from data: Data) -> MD70CandidateObjectRecord? {
        let base = MD70ObjectSection.firstObjectOffset

        guard
            let storedCenterY = data.md70Float64BE(at: base + centerYOffset),
            let storedCenterX = data.md70Float64BE(at: base + centerXOffset),
            let penWidth = data.md70Float64BE(at: base + penWidthOffset),
            let storedRadiusY = data.md70Float32BE(at: base + radiusYOffset),
            let storedRadiusX = data.md70Float32BE(at: base + radiusXOffset)
        else {
            return nil
        }

        return MD70CandidateObjectRecord(
            offset: base,
            centerX: storedCenterX / 10,
            centerY: storedCenterY / 10,
            radiusX: Double(storedRadiusX) / 10,
            radiusY: Double(storedRadiusY) / 10,
            penWidth: penWidth
        )
    }
}

private extension Data {
    func md70UInt32LE(at offset: Int) -> UInt32? {
        guard offset >= 0, offset + 4 <= count else { return nil }
        return UInt32(self[offset])
            | (UInt32(self[offset + 1]) << 8)
            | (UInt32(self[offset + 2]) << 16)
            | (UInt32(self[offset + 3]) << 24)
    }

    func md70UInt32BE(at offset: Int) -> UInt32? {
        guard offset >= 0, offset + 4 <= count else { return nil }
        return (UInt32(self[offset]) << 24)
            | (UInt32(self[offset + 1]) << 16)
            | (UInt32(self[offset + 2]) << 8)
            | UInt32(self[offset + 3])
    }

    func md70UInt64BE(at offset: Int) -> UInt64? {
        guard offset >= 0, offset + 8 <= count else { return nil }
        var value: UInt64 = 0
        for byteOffset in 0..<8 {
            value = (value << 8) | UInt64(self[offset + byteOffset])
        }
        return value
    }

    func md70Float32BE(at offset: Int) -> Float? {
        guard let bits = md70UInt32BE(at: offset) else { return nil }
        return Float(bitPattern: bits)
    }

    func md70Float64BE(at offset: Int) -> Double? {
        guard let bits = md70UInt64BE(at: offset) else { return nil }
        return Double(bitPattern: bits)
    }
}
