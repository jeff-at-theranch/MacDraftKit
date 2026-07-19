import Foundation

public struct MD70ObjectSection: Sendable {
    public static let objectCountOffset = 0x5117
    public static let firstObjectOffset = 0x511B

    public let declaredObjectCount: Int
    public let objects: [any MD70DrawingObject]

    public init(
        declaredObjectCount: Int,
        objects: [any MD70DrawingObject]
    ) {
        self.declaredObjectCount = declaredObjectCount
        self.objects = objects
    }

    public var firstObject: (any MD70DrawingObject)? {
        objects.first
    }

    public static func parse(from data: Data) -> MD70ObjectSection? {
        let reader = MD70BinaryReader(data: data)

    guard
        let rawCount = reader.uint32LE(at: objectCountOffset),
        let declaredCount = Int(exactly: rawCount)
    else {
        return nil
    }



        
        var objects: [any MD70DrawingObject] = []
        objects.reserveCapacity(declaredCount)

        var recordOffset = firstObjectOffset

        for _ in 0..<declaredCount {
            guard
                let rawTypeCode = reader.uint8(at: recordOffset),
                let storedLength = reader.uint32BE(at: recordOffset + 1)
            else {
                break
            }

            let header = MD70ObjectHeader(
                offset: recordOffset,
                rawTypeCode: rawTypeCode,
                type: MD70ObjectType(rawValue: rawTypeCode),
                storedLength: storedLength
            )

            guard
                header.totalLength >= 12,
                header.endOffset > recordOffset,
                let rawRecord = reader.slice(
                    at: recordOffset,
                    count: header.totalLength
                )
            else {
                break
            }

            objects.append(
                MD70ObjectDecoder.decode(
                    header: header,
                    record: rawRecord
                )
            )

            recordOffset = header.endOffset
        }

        return MD70ObjectSection(
            declaredObjectCount: declaredCount,
            objects: objects
        )
    }
}
