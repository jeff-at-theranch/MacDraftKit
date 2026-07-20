import Foundation

public struct MD70Ellipse: MD70DrawingObject {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?
    public let bounds: MD70Bounds?
    public let style: MD70ObjectStyle
    public let rawRecord: Data

    public var penWidth: Double? {
        style.penWidth
    }

    public var strokeColor: MD70Color? {
        style.strokeColor
    }

    public var strokePresetIndex: UInt8? {
        style.strokePresetIndex
    }

    public var isFillEnabled: Bool {
        style.isFillEnabled
    }

    public var fillColor: MD70Color? {
        style.fillColor
    }

    public var fillPresetIndex: UInt8? {
        style.fillPresetIndex
    }
}
