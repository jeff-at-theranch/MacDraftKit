import Foundation

public struct MD70Rectangle: MD70DrawingObject, Equatable {
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
    
    /*
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
     */
}
