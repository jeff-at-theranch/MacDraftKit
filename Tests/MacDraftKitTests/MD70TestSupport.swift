import Foundation
import XCTest
@testable import MacDraftKit

struct MD70TestColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    static let black = MD70TestColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = MD70TestColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let macDraftRed = MD70TestColor(
        red: 0.864927,
        green: 0.034211,
        blue: 0.025910,
        alpha: 1
    )
}

enum MD70TestSupport {
    static let accuracy = 0.000_001
    static let storageScale = 10.0

    static func writeStyle(
        to data: inout Data,
        penWidth: Double = 1,
        strokeColor: MD70TestColor = .black,
        strokePresetIndex: UInt8 = 2,
        isFillEnabled: Bool = false,
        fillColor: MD70TestColor = .white,
        fillPresetIndex: UInt8 = 0
    ) {
        writeColor(strokeColor, to: &data, offsets: (0x4D, 0x51, 0x55, 0x59))
        data[0x64] = strokePresetIndex
        writeFloat64BE(penWidth, to: &data, at: 0x69)
        writeColor(fillColor, to: &data, offsets: (0xA3, 0xA7, 0xAB, 0xAF))
        data[0xB6] = isFillEnabled ? 1 : 0
        data[0xBA] = fillPresetIndex
    }

    static func assertStyle(
        _ style: MD70ObjectStyle,
        penWidth: Double,
        strokeColor: MD70TestColor,
        strokePresetIndex: UInt8,
        isFillEnabled: Bool,
        fillColor: MD70TestColor,
        fillPresetIndex: UInt8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTAssertEqual(try XCTUnwrap(style.penWidth), penWidth, accuracy: accuracy, file: file, line: line)
        assertColor(try XCTUnwrap(style.strokeColor), equals: strokeColor, file: file, line: line)
        XCTAssertEqual(style.strokePresetIndex, strokePresetIndex, file: file, line: line)
        XCTAssertEqual(style.isFillEnabled, isFillEnabled, file: file, line: line)
        assertColor(try XCTUnwrap(style.fillColor), equals: fillColor, file: file, line: line)
        XCTAssertEqual(style.fillPresetIndex, fillPresetIndex, file: file, line: line)
    }

    static func assertColor(
        _ actual: MD70Color,
        equals expected: MD70TestColor,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.red, expected.red, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.green, expected.green, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.blue, expected.blue, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.alpha, expected.alpha, accuracy: accuracy, file: file, line: line)
    }

    static func writeScaledFloat64BE(_ value: Double, to data: inout Data, at offset: Int) {
        writeFloat64BE(value * storageScale, to: &data, at: offset)
    }

    static func writeUInt32BE(_ value: UInt32, to data: inout Data, at offset: Int) {
        let bits = value.bigEndian
        withUnsafeBytes(of: bits) { data.replaceSubrange(offset..<(offset + 4), with: $0) }
    }

    static func writeFloat64BE(_ value: Double, to data: inout Data, at offset: Int) {
        let bits = value.bitPattern.bigEndian
        withUnsafeBytes(of: bits) { data.replaceSubrange(offset..<(offset + 8), with: $0) }
    }

    private static func writeFloat32BE(_ value: Float, to data: inout Data, at offset: Int) {
        let bits = value.bitPattern.bigEndian
        withUnsafeBytes(of: bits) { data.replaceSubrange(offset..<(offset + 4), with: $0) }
    }

    private static func writeColor(
        _ color: MD70TestColor,
        to data: inout Data,
        offsets: (Int, Int, Int, Int)
    ) {
        writeFloat32BE(Float(color.red), to: &data, at: offsets.0)
        writeFloat32BE(Float(color.green), to: &data, at: offsets.1)
        writeFloat32BE(Float(color.blue), to: &data, at: offsets.2)
        writeFloat32BE(Float(color.alpha), to: &data, at: offsets.3)
    }
}
