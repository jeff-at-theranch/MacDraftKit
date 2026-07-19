import Foundation

public enum MD70ObjectType: UInt8, Sendable, Equatable, CaseIterable {
    case line = 0x01
    case rectangle = 0x0A
    case roundedRectangle = 0x0B
    case circle = 0x14
    case arc = 0x15
    case ellipse = 0x18
    case bezier = 0x20
    case text = 0x29
    case polygon = 0x33

    public var displayName: String {
        switch self {
        case .line: return "Line"
        case .rectangle: return "Rectangle"
        case .roundedRectangle: return "Rounded rectangle"
        case .circle: return "Circle"
        case .arc: return "Arc"
        case .ellipse: return "Ellipse"
        case .bezier: return "Bezier"
        case .text: return "Text"
        case .polygon: return "Polygon"
        }
    }
}

public struct MD70ObjectHeader: Sendable, Equatable {
    public let offset: Int
    public let rawTypeCode: UInt8
    public let type: MD70ObjectType?
    public let storedLength: UInt32

    public init(
        offset: Int,
        rawTypeCode: UInt8,
        type: MD70ObjectType?,
        storedLength: UInt32
    ) {
        self.offset = offset
        self.rawTypeCode = rawTypeCode
        self.type = type
        self.storedLength = storedLength
    }

    /// Confirmed record traversal rule: stored payload length plus 12 framing bytes.
    public var totalLength: Int { Int(storedLength) + 12 }

    public var endOffset: Int {
        let (end, overflow) = offset.addingReportingOverflow(totalLength)
        return overflow ? Int.max : end
    }
}

public struct MD70Point: Sendable, Equatable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct MD70Bounds: Sendable, Equatable {
    public let left: Double
    public let top: Double
    public let right: Double
    public let bottom: Double

    public init(left: Double, top: Double, right: Double, bottom: Double) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    public var width: Double { right - left }
    public var height: Double { bottom - top }
}

public protocol MD70DrawingObject: Sendable {
    var header: MD70ObjectHeader { get }
    var anchor: MD70Point? { get }
    var bounds: MD70Bounds? { get }
    var penWidth: Double? { get }
    var rawRecord: Data { get }
}

public extension MD70DrawingObject {
    var offset: Int { header.offset }
    var rawTypeCode: UInt8 { header.rawTypeCode }
    var type: MD70ObjectType? { header.type }
    var storedLength: UInt32 { header.storedLength }
    var totalLength: Int { header.totalLength }
}

public struct MD70Rectangle: MD70DrawingObject, Equatable {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?
    public let bounds: MD70Bounds?
    public let penWidth: Double?
    public let rawRecord: Data

    public init(
        header: MD70ObjectHeader,
        anchor: MD70Point?,
        bounds: MD70Bounds?,
        penWidth: Double?,
        rawRecord: Data
    ) {
        self.header = header
        self.anchor = anchor
        self.bounds = bounds
        self.penWidth = penWidth
        self.rawRecord = rawRecord
    }
}

public struct MD70UnknownObject: MD70DrawingObject, Equatable {
    public let header: MD70ObjectHeader
    public let anchor: MD70Point?
    public let penWidth: Double?
    public let rawRecord: Data

    public init(
        header: MD70ObjectHeader,
        anchor: MD70Point?,
        penWidth: Double?,
        rawRecord: Data
    ) {
        self.header = header
        self.anchor = anchor
        self.penWidth = penWidth
        self.rawRecord = rawRecord
    }

    public var bounds: MD70Bounds? { nil }
}
