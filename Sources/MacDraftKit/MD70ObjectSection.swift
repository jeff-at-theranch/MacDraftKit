import Foundation

public enum MD70ObjectType: UInt8, Sendable, Equatable, CaseIterable {
    case line = 0x01
    case rectangle = 0x0A
    case roundedRectangle = 0x0B
    case arc = 0x15
    case ellipse = 0x18
    case bezier = 0x20
    case text = 0x29
    case polygon = 0x33

    public var displayName: String {
        switch self {
        case .line: return "Line"
        case .rectangle: return "Rectangle"
        case .roundedRectangle: return "Rounded rectangle"
        case .arc: return "Arc"
        case .ellipse: return "Ellipse"
        case .bezier: return "Bezier"
        case .text: return "Text"
        case .polygon: return "Polygon"
        }
    }
}

/// Confirmed fields from one fixed-size MD70 drawing-object record.
public struct MD70CandidateObjectRecord: Sendable, Equatable {
    public let offset: Int
    public let rawTypeCode: UInt8
    public let type: MD70ObjectType?
    public let centerX: Double
    public let centerY: Double
    public let radiusX: Double
    public let radiusY: Double
    public let penWidth: Double

    public var width: Double { radiusX * 2 }
    public var height: Double { radiusY * 2 }
}

/// Confirmed information from the MD70 drawing-object section.
public struct MD70ObjectSection: Sendable, Equatable {
    public let declaredObjectCount: Int
    public let objects: [MD70CandidateObjectRecord]

    public var firstObject: MD70CandidateObjectRecord? {
        objects.first
    }

    private static let objectCountOffset = 0x5117
    private static let firstRecordOffset = 0x511B
    private static let recordStride = 0x10D

    private static let centerYOffset = 0x09
    private static let centerXOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let radiusYOffset = 0xEB
    private static let radiusXOffset = 0xEF

    public static func parse(from data: Data) -> MD70ObjectSection? {
        guard let rawCount = readUInt32LittleEndian(
            from: data,
            at: objectCountOffset
        ) else {
            return nil
        }

        let declaredCount = Int(rawCount)
        var records: [MD70CandidateObjectRecord] = []
        records.reserveCapacity(declaredCount)

        for index in 0..<declaredCount {
            let (strideProduct, multiplyOverflow) =
                index.multipliedReportingOverflow(by: recordStride)
            let (recordOffset, addOverflow) =
                firstRecordOffset.addingReportingOverflow(strideProduct)

            guard !multiplyOverflow, !addOverflow,
                  let record = parseRecord(from: data, at: recordOffset)
            else {
                break
            }

            records.append(record)
        }

        return MD70ObjectSection(
            declaredObjectCount: declaredCount,
            objects: records
        )
    }

    private static func parseRecord(
        from data: Data,
        at recordOffset: Int
    ) -> MD70CandidateObjectRecord? {
        guard recordOffset >= 0, recordOffset < data.count else {
            return nil
        }

        let rawTypeCode = data[recordOffset]

        guard
            let storedCenterY = readFloat64BigEndian(
                from: data,
                at: recordOffset + centerYOffset
            ),
            let storedCenterX = readFloat64BigEndian(
                from: data,
                at: recordOffset + centerXOffset
            ),
            let penWidth = readFloat64BigEndian(
                from: data,
                at: recordOffset + penWidthOffset
            ),
            let storedRadiusY = readFloat32BigEndian(
                from: data,
                at: recordOffset + radiusYOffset
            ),
            let storedRadiusX = readFloat32BigEndian(
                from: data,
                at: recordOffset + radiusXOffset
            )
        else {
            return nil
        }

        return MD70CandidateObjectRecord(
            offset: recordOffset,
            rawTypeCode: rawTypeCode,
            type: MD70ObjectType(rawValue: rawTypeCode),
            centerX: storedCenterX / 10,
            centerY: storedCenterY / 10,
            radiusX: Double(storedRadiusX) / 10,
            radiusY: Double(storedRadiusY) / 10,
            penWidth: penWidth
        )
    }

    private static func readUInt32LittleEndian(
        from data: Data,
        at offset: Int
    ) -> UInt32? {
        guard let bytes = bytes(from: data, at: offset, count: 4) else {
            return nil
        }

        return UInt32(bytes[0])
            | (UInt32(bytes[1]) << 8)
            | (UInt32(bytes[2]) << 16)
            | (UInt32(bytes[3]) << 24)
    }

    private static func readFloat32BigEndian(
        from data: Data,
        at offset: Int
    ) -> Float? {
        guard let bytes = bytes(from: data, at: offset, count: 4) else {
            return nil
        }

        let bits = (UInt32(bytes[0]) << 24)
            | (UInt32(bytes[1]) << 16)
            | (UInt32(bytes[2]) << 8)
            | UInt32(bytes[3])

        return Float(bitPattern: bits)
    }

    private static func readFloat64BigEndian(
        from data: Data,
        at offset: Int
    ) -> Double? {
        guard let bytes = bytes(from: data, at: offset, count: 8) else {
            return nil
        }

        var bits: UInt64 = 0
        for byte in bytes {
            bits = (bits << 8) | UInt64(byte)
        }

        return Double(bitPattern: bits)
    }

    private static func bytes(
        from data: Data,
        at offset: Int,
        count: Int
    ) -> Data? {
        guard offset >= 0, count >= 0 else {
            return nil
        }

        let (end, overflow) = offset.addingReportingOverflow(count)
        guard !overflow, end <= data.count else {
            return nil
        }

        return data.subdata(in: offset..<end)
    }
}
