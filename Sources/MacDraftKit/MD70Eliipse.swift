import Foundation

struct MD70Ellipse: MD70DrawingObject {
    let header: MD70ObjectHeader
    let anchor: MD70Point?
    let bounds: MD70Bounds?
    let penWidth: Double?
    let rawRecord: Data
}
