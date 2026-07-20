import Foundation

enum MD70PolygonParametersDecoder {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let rotationOffset = 0x45
    private static let penWidthOffset = 0x69

    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70PolygonParameters {
        let reader = MD70BinaryReader(data: record)

        let anchorY = reader.float64BE(
            at: anchorTopOffset
        ).map {
            $0 / storageScale
        }

        let anchorX = reader.float64BE(
            at: anchorLeftOffset
        ).map {
            $0 / storageScale
        }

        let anchor: MD70Point?
        if let anchorX, let anchorY {
            anchor = MD70Point(
                x: anchorX,
                y: anchorY
            )
        } else {
            anchor = nil
        }

        return MD70PolygonParameters(
            header: header,
            anchor: anchor,
            rotationDegrees: reader.float64BE(
                at: rotationOffset
            ),
            penWidth: reader.float64BE(
                at: penWidthOffset
            ),
            rawRecord: record
        )
    }
}
