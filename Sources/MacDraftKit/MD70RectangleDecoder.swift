import Foundation

enum MD70RectangleDecoder {
    private static let topOffset = 0x09
    private static let leftOffset = 0x11
    private static let rightOffset = 0xEF
    private static let bottomOffset = 0x107

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Rectangle {
        let reader = MD70BinaryReader(
            data: record
        )

        return MD70Rectangle(
            header: header,
            anchor:
                MD70CommonObjectDecoder.decodeAnchor(
                    from: reader
                ),
            bounds:
                MD70CommonObjectDecoder.decodeBounds(
                    from: reader,
                    leftOffset: leftOffset,
                    topOffset: topOffset,
                    rightOffset: rightOffset,
                    bottomOffset: bottomOffset
                ),
            style:
                MD70ObjectStyleDecoder.decode(
                    from: reader
                ),
            rawRecord: record
        )
    }
}
