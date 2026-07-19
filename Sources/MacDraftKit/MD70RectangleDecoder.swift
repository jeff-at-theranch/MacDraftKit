import Foundation

enum MD70RectangleDecoder {
    private static let topOffset = 0x09
    private static let leftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let rightOffset = 0xEF
    private static let bottomOffset = 0x107
    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Rectangle {
        let reader = MD70BinaryReader(data: record)

        let top = reader.float64BE(at: topOffset).map { $0 / storageScale }
        let left = reader.float64BE(at: leftOffset).map { $0 / storageScale }
        let right = reader.float64BE(at: rightOffset).map { $0 / storageScale }
        let bottom = reader.float64BE(at: bottomOffset).map { $0 / storageScale }

        let anchor: MD70Point?
        if let left, let top {
            anchor = MD70Point(x: left, y: top)
        } else {
            anchor = nil
        }

        let bounds: MD70Bounds?
        if let left, let top, let right, let bottom {
            bounds = MD70Bounds(
                left: left,
                top: top,
                right: right,
                bottom: bottom
            )
        } else {
            bounds = nil
        }

        return MD70Rectangle(
            header: header,
            anchor: anchor,
            bounds: bounds,
            penWidth: reader.float64BE(at: penWidthOffset),
            rawRecord: record
        )
    }
}
