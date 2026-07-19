import Foundation

enum MD70RoundedRectangleDecoder {
    private static let topOffset = 0x09
    private static let leftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let rightOffset = 0xEF
    private static let bottomOffset = 0x107
    private static let cornerWidthOffset = 0x153
    private static let cornerHeightOffset = 0x15B

    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70RoundedRectangle {
        let reader = MD70BinaryReader(data: record)

        let top = scaledValue(
            reader.float64BE(at: topOffset)
        )

        let left = scaledValue(
            reader.float64BE(at: leftOffset)
        )

        let right = scaledValue(
            reader.float64BE(at: rightOffset)
        )

        let bottom = scaledValue(
            reader.float64BE(at: bottomOffset)
        )

        let cornerWidth = scaledValue(
            reader.float64BE(at: cornerWidthOffset)
        )

        let cornerHeight = scaledValue(
            reader.float64BE(at: cornerHeightOffset)
        )

        let anchor: MD70Point?
        if let left, let top {
            anchor = MD70Point(
                x: left,
                y: top
            )
        } else {
            anchor = nil
        }

        let bounds: MD70Bounds?
        if
            let left,
            let top,
            let right,
            let bottom
        {
            bounds = MD70Bounds(
                left: left,
                top: top,
                right: right,
                bottom: bottom
            )
        } else {
            bounds = nil
        }

        return MD70RoundedRectangle(
            header: header,
            anchor: anchor,
            bounds: bounds,
            cornerWidth: cornerWidth,
            cornerHeight: cornerHeight,
            penWidth: reader.float64BE(
                at: penWidthOffset
            ),
            rawRecord: record
        )
    }

    private static func scaledValue(
        _ value: Double?
    ) -> Double? {
        value.map {
            $0 / storageScale
        }
    }
}
