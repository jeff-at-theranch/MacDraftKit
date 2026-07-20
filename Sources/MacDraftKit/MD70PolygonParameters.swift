import Foundation

public struct MD70PolygonParameters: MD70DrawingObject {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?

    /// Stored polygon rotation in degrees.
    ///
    /// Positive values appear to rotate counterclockwise in
    /// MacDraft document coordinates.
    public let rotationDegrees: Double?

    public let bounds: MD70Bounds? = nil
    public let penWidth: Double?
    public let rawRecord: Data
}
