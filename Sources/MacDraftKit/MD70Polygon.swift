import Foundation

public struct MD70Polygon: MD70DrawingObject {
    public let header: MD70ObjectHeader

    public let anchor: MD70Point?
    public let vertices: [MD70Point]

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

    public var shapeName: String {
        switch vertices.count {
        case 0:
            return "Empty Polygon"
        case 1:
            return "Point"
        case 2:
            return "Line"
        case 3:
            return "Triangle"
        case 4:
            return "Quadrilateral"
        case 5:
            return "Pentagon"
        case 6:
            return "Hexagon"
        case 7:
            return "Heptagon"
        case 8:
            return "Octagon"
        case 9:
            return "Nonagon"
        case 10:
            return "Decagon"
        case 11:
            return "Hendecagon"
        case 12:
            return "Dodecagon"
        default:
            return "\(vertices.count)-gon"
        }
    }

    public var bounds: MD70Bounds? {
        guard let firstVertex = vertices.first else {
            return nil
        }

        var left = firstVertex.x
        var top = firstVertex.y
        var right = firstVertex.x
        var bottom = firstVertex.y

        for vertex in vertices.dropFirst() {
            left = min(left, vertex.x)
            top = min(top, vertex.y)
            right = max(right, vertex.x)
            bottom = max(bottom, vertex.y)
        }

        return MD70Bounds(
            left: left,
            top: top,
            right: right,
            bottom: bottom
        )
    }

    public var center: MD70Point? {
        guard !vertices.isEmpty else {
            return nil
        }

        let totals = vertices.reduce(
            into: (x: 0.0, y: 0.0)
        ) { result, vertex in
            result.x += vertex.x
            result.y += vertex.y
        }

        let count = Double(vertices.count)

        return MD70Point(
            x: totals.x / count,
            y: totals.y / count
        )
    }

    public var firstVertexAngleDegrees: Double? {
        guard
            let center,
            let firstVertex = vertices.first
        else {
            return nil
        }

        let deltaX = firstVertex.x - center.x
        let deltaY = firstVertex.y - center.y

        var degrees =
            atan2(deltaY, deltaX) *
            180.0 /
            Double.pi

        if degrees < 0 {
            degrees += 360.0
        }

        return degrees
    }
}
