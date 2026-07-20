import Foundation

enum MD70CommonObjectDecoder {
    private static let storageScale = 10.0

    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11

    static func scaledFloat64(
        from reader: MD70BinaryReader,
        at offset: Int
    ) -> Double? {
        reader.float64BE(at: offset).map {
            $0 / storageScale
        }
    }

    static func decodeAnchor(
        from reader: MD70BinaryReader
    ) -> MD70Point? {
        decodePoint(
            from: reader,
            yOffset: anchorTopOffset,
            xOffset: anchorLeftOffset
        )
    }

    static func decodePoint(
        from reader: MD70BinaryReader,
        yOffset: Int,
        xOffset: Int
    ) -> MD70Point? {
        guard
            let y = scaledFloat64(
                from: reader,
                at: yOffset
            ),
            let x = scaledFloat64(
                from: reader,
                at: xOffset
            )
        else {
            return nil
        }

        return MD70Point(
            x: x,
            y: y
        )
    }

    static func decodeBounds(
        from reader: MD70BinaryReader,
        leftOffset: Int,
        topOffset: Int,
        rightOffset: Int,
        bottomOffset: Int
    ) -> MD70Bounds? {
        guard
            let left = scaledFloat64(
                from: reader,
                at: leftOffset
            ),
            let top = scaledFloat64(
                from: reader,
                at: topOffset
            ),
            let right = scaledFloat64(
                from: reader,
                at: rightOffset
            ),
            let bottom = scaledFloat64(
                from: reader,
                at: bottomOffset
            )
        else {
            return nil
        }

        return MD70Bounds(
            left: left,
            top: top,
            right: right,
            bottom: bottom
        )
    }
}
