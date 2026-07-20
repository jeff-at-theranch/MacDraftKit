// Sources/MacDraftKit/MD70ObjectStyle.swift

import Foundation

public struct MD70ObjectStyle: Equatable, Sendable {
    public let strokeColor: MD70Color?
    public let strokePresetIndex: UInt8?
    public let penWidth: Double?

    public let isFillEnabled: Bool
    public let fillColor: MD70Color?
    public let fillPresetIndex: UInt8?

    public init(
        strokeColor: MD70Color?,
        strokePresetIndex: UInt8?,
        penWidth: Double?,
        isFillEnabled: Bool,
        fillColor: MD70Color?,
        fillPresetIndex: UInt8?
    ) {
        self.strokeColor = strokeColor
        self.strokePresetIndex = strokePresetIndex
        self.penWidth = penWidth
        self.isFillEnabled = isFillEnabled
        self.fillColor = fillColor
        self.fillPresetIndex = fillPresetIndex
    }
}
