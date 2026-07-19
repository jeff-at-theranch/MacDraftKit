import Foundation

public struct MD70Text: MD70DrawingObject {
    public let header: MD70ObjectHeader

    /// Text-object anchor. Not decoded yet.
    public let anchor: MD70Point?

    /// Text-object bounds. Not decoded yet.
    public let bounds: MD70Bounds?

    /// Text-object pen width. Not decoded yet.
    public let penWidth: Double?

    /// Complete variable-length MD70 object record.
    public let rawRecord: Data

    /// Raw embedded RTF document.
    public let rtfData: Data

    public init(
        header: MD70ObjectHeader,
        rawRecord: Data,
        rtfData: Data,
        anchor: MD70Point? = nil,
        bounds: MD70Bounds? = nil,
        penWidth: Double? = nil
    ) {
        self.header = header
        self.anchor = anchor
        self.bounds = bounds
        self.penWidth = penWidth
        self.rawRecord = rawRecord
        self.rtfData = rtfData
    }
}

