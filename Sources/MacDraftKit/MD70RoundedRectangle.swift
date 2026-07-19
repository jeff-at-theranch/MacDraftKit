import Foundation

public struct MD70RoundedRectangle: MD70DrawingObject {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?
    public let bounds: MD70Bounds?

    /// Width of the complete corner arc in points.
    public let cornerWidth: Double?

    /// Height of the complete corner arc in points.
    public let cornerHeight: Double?

    /// Horizontal corner radius in points.
    public var cornerRadiusX: Double? {
        cornerWidth.map { $0 / 2.0 }
    }

    /// Vertical corner radius in points.
    public var cornerRadiusY: Double? {
        cornerHeight.map { $0 / 2.0 }
    }

    public let penWidth: Double?
    public let rawRecord: Data
}
