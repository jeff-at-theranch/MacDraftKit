import Foundation

public struct MD70Circle: MD70DrawingObject {
    public let header: MD70ObjectHeader

    /// MacDraft's stored circle anchor.
    ///
    /// Evidence indicates this is the first endpoint of a diagonal
    /// diameter running down and to the right at 45 degrees.
    public let anchor: MD70Point?

    /// The visual center derived from the stored anchor and radius.
    public let center: MD70Point?

    /// Circle radius in points.
    public let radius: Double?

    public var diameter: Double? {
        radius.map { $0 * 2.0 }
    }

    /// Axis-aligned visual bounds of the circle.
    public var bounds: MD70Bounds? {
        guard
            let center,
            let radius
        else {
            return nil
        }

        return MD70Bounds(
            left: center.x - radius,
            top: center.y - radius,
            right: center.x + radius,
            bottom: center.y + radius
        )
    }

    public let penWidth: Double?
    public let rawRecord: Data
}
