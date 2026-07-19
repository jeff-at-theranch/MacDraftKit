import Foundation

struct MD70Line: MD70DrawingObject {
    let header: MD70ObjectHeader

    let startPoint: MD70Point?
    let endPoint: MD70Point?

    var anchor: MD70Point? {
        startPoint
    }

    var bounds: MD70Bounds? {
        guard let startPoint, let endPoint else {
            return nil
        }

        return MD70Bounds(
            left: min(startPoint.x, endPoint.x),
            top: min(startPoint.y, endPoint.y),
            right: max(startPoint.x, endPoint.x),
            bottom: max(startPoint.y, endPoint.y)
        )
    }

    let penWidth: Double?
    let rawRecord: Data
}
