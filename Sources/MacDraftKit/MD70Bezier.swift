import Foundation

public enum MD70BezierNodeKind:
    Equatable,
    Sendable
{
    case corner
    case smooth
}


public struct MD70BezierHandle: Equatable, Sendable {
    public let anchor: MD70Point
    public let controlPoint: MD70Point

    public init(
        anchor: MD70Point,
        controlPoint: MD70Point
    ) {
        self.anchor = anchor
        self.controlPoint = controlPoint
    }

    public var vector: MD70Point {
        MD70Point(
            x: controlPoint.x - anchor.x,
            y: controlPoint.y - anchor.y
        )
    }

    public var length: Double {
        hypot(
            controlPoint.x - anchor.x,
            controlPoint.y - anchor.y
        )
    }
    
    public func isCollapsed(
        tolerance: Double = 0.000_001
    ) -> Bool {
        length <= tolerance
    }

    public func isActive(
        tolerance: Double = 0.000_001
    ) -> Bool {
        !isCollapsed(tolerance: tolerance)
    }

    /// Clockwise visual angle from the positive X axis.
    ///
    /// MD70 document coordinates increase downward on the Y axis,
    /// so atan2(deltaY, deltaX) maps naturally to clockwise screen
    /// rotation.
    public var angleDegrees: Double {
        var degrees =
            atan2(
                controlPoint.y - anchor.y,
                controlPoint.x - anchor.x
            ) *
            180.0 /
            Double.pi

        if degrees < 0 {
            degrees += 360.0
        }

        return degrees
    }
}

public struct MD70BezierSegment: Equatable, Sendable {
    public let start: MD70Point
    public let control1: MD70Point
    public let control2: MD70Point
    public let end: MD70Point

    public init(
        start: MD70Point,
        control1: MD70Point,
        control2: MD70Point,
        end: MD70Point
    ) {
        self.start = start
        self.control1 = control1
        self.control2 = control2
        self.end = end
    }

    public var outgoingHandle: MD70BezierHandle {
        MD70BezierHandle(
            anchor: start,
            controlPoint: control1
        )
    }

    public var incomingHandle: MD70BezierHandle {
        MD70BezierHandle(
            anchor: end,
            controlPoint: control2
        )
    }
    
    public static func nodeKind(
        incomingHandle: MD70BezierHandle,
        outgoingHandle: MD70BezierHandle,
        collapsedTolerance: Double = 1.0,
        angularToleranceDegrees: Double = 3.0
    ) -> MD70BezierNodeKind {
        if
            incomingHandle.length <= collapsedTolerance,
            outgoingHandle.length <= collapsedTolerance
        {
            return .corner
        }

        let incomingAngle =
            incomingHandle.angleDegrees

        let outgoingAngle =
            outgoingHandle.angleDegrees

        var difference = abs(
            incomingAngle - outgoingAngle
        )

        if difference > 180 {
            difference = 360 - difference
        }

        let oppositeDifference =
            abs(180 - difference)

        return oppositeDifference <= angularToleranceDegrees
            ? .smooth
            : .corner
    }
    
    
}

public struct MD70Bezier: MD70DrawingObject {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?
    public let points: [MD70Point]
    public let segments: [MD70BezierSegment]
    public let style: MD70ObjectStyle
    public let rawRecord: Data

    public init(
        header: MD70ObjectHeader,
        anchor: MD70Point?,
        points: [MD70Point],
        segments: [MD70BezierSegment],
        style: MD70ObjectStyle,
        rawRecord: Data
    ) {
        self.header = header
        self.anchor = anchor
        self.points = points
        self.segments = segments
        self.style = style
        self.rawRecord = rawRecord
    }

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

    public var isClosed: Bool {
        guard
            let first = points.first,
            let last = points.last
        else {
            return false
        }

        return first == last
    }
    
    

    /// Bounds of all stored anchors and control points.
    ///
    /// These are control-point bounds, not the mathematically exact
    /// extrema of the cubic curves.
    public var bounds: MD70Bounds? {
        guard let firstPoint = points.first else {
            return nil
        }

        var left = firstPoint.x
        var top = firstPoint.y
        var right = firstPoint.x
        var bottom = firstPoint.y

        for point in points.dropFirst() {
            left = min(left, point.x)
            top = min(top, point.y)
            right = max(right, point.x)
            bottom = max(bottom, point.y)
        }

        return MD70Bounds(
            left: left,
            top: top,
            right: right,
            bottom: bottom
        )
    }
}
