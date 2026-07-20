import Foundation

enum MD70ObjectDecoder {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> any MD70DrawingObject {
        switch header.type {
        case .rectangle:
            return MD70RectangleDecoder.decode(
                header: header,
                record: record
            )

        case .text:
            return MD70TextDecoder.decode(
                header: header,
                record: record
            )

        case .ellipse:
            return MD70EllipseDecoder.decode(
                header: header,
                record: record
            )

        case .line:
            return MD70LineDecoder.decode(
                header: header,
                record: record
            )

        case .circle:
            return MD70CircleDecoder.decode(
                header: header,
                record: record
            )

        case .roundedRectangle:
            return MD70RoundedRectangleDecoder.decode(
                header: header,
                record: record
            )

        case .polygon:
            return MD70PolygonDecoder.decode(
                header: header,
                record: record
            )

        case .polygonParameters:
            return MD70PolygonParametersDecoder.decode(
                header: header,
                record: record
            )

        case .bezier:
            return MD70BezierDecoder.decode(
                header: header,
                record: record
            )

        default:
            return decodeUnknown(
                header: header,
                record: record
            )
        }
    }

    private static func decodeUnknown(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70UnknownObject {
        let reader = MD70BinaryReader(data: record)

        let top = reader.float64BE(
            at: anchorTopOffset
        ).map {
            $0 / storageScale
        }

        let left = reader.float64BE(
            at: anchorLeftOffset
        ).map {
            $0 / storageScale
        }

        let anchor: MD70Point?

        if let left, let top {
            anchor = MD70Point(
                x: left,
                y: top
            )
        } else {
            anchor = nil
        }

        return MD70UnknownObject(
            header: header,
            anchor: anchor,
            penWidth: reader.float64BE(
                at: penWidthOffset
            ),
            rawRecord: record
        )
    }
}
