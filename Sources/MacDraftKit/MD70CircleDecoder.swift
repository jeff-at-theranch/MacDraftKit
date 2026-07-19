import Foundation

enum MD70CircleDecoder {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let radiusOffset = 0xCB

    private static let storageScale = 10.0
    private static let squareRootOfTwo = sqrt(2.0)

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Circle {
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

        let radius = reader.float64BE(
            at: radiusOffset
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

        let center: MD70Point?
        if
            let anchor,
            let radius
        {
            let diagonalRadiusComponent =
                radius / squareRootOfTwo

            center = MD70Point(
                x: anchor.x + diagonalRadiusComponent,
                y: anchor.y + diagonalRadiusComponent
            )
        } else {
            center = nil
        }

        return MD70Circle(
            header: header,
            anchor: anchor,
            center: center,
            radius: radius,
            penWidth: reader.float64BE(
                at: penWidthOffset
            ),
            rawRecord: record
        )
    }
}
