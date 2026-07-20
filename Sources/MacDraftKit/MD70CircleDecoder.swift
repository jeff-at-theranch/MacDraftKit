import Foundation

enum MD70CircleDecoder {
    private static let radiusOffset = 0xCB
    private static let squareRootOfTwo = sqrt(2.0)

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Circle {
        let reader = MD70BinaryReader(
            data: record
        )

        let anchor =
            MD70CommonObjectDecoder.decodeAnchor(
                from: reader
            )

        let radius =
            MD70CommonObjectDecoder.scaledFloat64(
                from: reader,
                at: radiusOffset
            )

        let center: MD70Point?

        if
            let anchor,
            let radius
        {
            let component =
                radius / squareRootOfTwo

            center = MD70Point(
                x: anchor.x + component,
                y: anchor.y + component
            )
        } else {
            center = nil
        }

        return MD70Circle(
            header: header,
            anchor: anchor,
            center: center,
            radius: radius,
            style:
                MD70ObjectStyleDecoder.decode(
                    from: reader
                ),
            rawRecord: record
        )
    }
}
