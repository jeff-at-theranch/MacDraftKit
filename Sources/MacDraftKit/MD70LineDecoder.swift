import Foundation

enum MD70LineDecoder {
    private static let startTopOffset = 0x09
    private static let startLeftOffset = 0x11

    private static let endTopOffset = 0xCD
    private static let endLeftOffset = 0xD5

    private static let penWidthOffset = 0x69

    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Line {

        let reader = MD70BinaryReader(data: record)

        let startY = reader.float64BE(at: startTopOffset).map {
            $0 / storageScale
        }

        let startX = reader.float64BE(at: startLeftOffset).map {
            $0 / storageScale
        }

        let endY = reader.float64BE(at: endTopOffset).map {
            $0 / storageScale
        }

        let endX = reader.float64BE(at: endLeftOffset).map {
            $0 / storageScale
        }

        let anchor: MD70Point?
        if let startX, let startY {
            anchor = MD70Point(
                x: startX,
                y: startY
            )
        } else {
            anchor = nil
        }

        let endPoint: MD70Point?
        if let endX, let endY {
            endPoint = MD70Point(
                x: endX,
                y: endY
            )
        } else {
            endPoint = nil
        }

        return MD70Line(
                header: header,
                startPoint: anchor,
                endPoint: endPoint,
                penWidth: reader.float64BE(at: penWidthOffset),
                rawRecord: record
            )
    }
}
