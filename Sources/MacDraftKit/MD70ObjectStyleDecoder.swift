// Sources/MacDraftKit/MD70ObjectStyleDecoder.swift

import Foundation

enum MD70ObjectStyleDecoder {
    private static let strokeRedOffset = 0x4D
    private static let strokeGreenOffset = 0x51
    private static let strokeBlueOffset = 0x55
    private static let strokeAlphaOffset = 0x59
    private static let strokePresetIndexOffset = 0x64
    private static let penWidthOffset = 0x69

    private static let fillRedOffset = 0xA3
    private static let fillGreenOffset = 0xA7
    private static let fillBlueOffset = 0xAB
    private static let fillAlphaOffset = 0xAF
    private static let fillEnabledOffset = 0xB6
    private static let fillPresetIndexOffset = 0xBA

    static func decode(
        from reader: MD70BinaryReader
    ) -> MD70ObjectStyle {
        MD70ObjectStyle(
            strokeColor: decodeColor(
                from: reader,
                redOffset: strokeRedOffset,
                greenOffset: strokeGreenOffset,
                blueOffset: strokeBlueOffset,
                alphaOffset: strokeAlphaOffset
            ),
            strokePresetIndex: reader.uint8(
                at: strokePresetIndexOffset
            ),
            penWidth: reader.float64BE(
                at: penWidthOffset
            ),
            isFillEnabled:
                reader.uint8(at: fillEnabledOffset) == 1,
            fillColor: decodeColor(
                from: reader,
                redOffset: fillRedOffset,
                greenOffset: fillGreenOffset,
                blueOffset: fillBlueOffset,
                alphaOffset: fillAlphaOffset
            ),
            fillPresetIndex: reader.uint8(
                at: fillPresetIndexOffset
            )
        )
    }

    private static func decodeColor(
        from reader: MD70BinaryReader,
        redOffset: Int,
        greenOffset: Int,
        blueOffset: Int,
        alphaOffset: Int
    ) -> MD70Color? {
        guard
            let red = reader.float32BE(at: redOffset),
            let green = reader.float32BE(at: greenOffset),
            let blue = reader.float32BE(at: blueOffset),
            let alpha = reader.float32BE(at: alphaOffset)
        else {
            return nil
        }

        return MD70Color(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: Double(alpha)
        )
    }
}
