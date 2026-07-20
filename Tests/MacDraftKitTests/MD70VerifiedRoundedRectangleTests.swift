import Foundation
import XCTest
@testable import MacDraftKit

final class MD70VerifiedRoundedRectangleTests: XCTestCase {
    // MARK: - Shared geometry offsets

    private static let topOffset = 0x09
    private static let leftOffset = 0x11

    private static let rightOffset = 0xEF
    private static let bottomOffset = 0x107

    private static let cornerWidthOffset = 0x153
    private static let cornerHeightOffset = 0x15B

    // MARK: - Shared style offsets

    private static let strokeRedOffset = 0x4D
    private static let strokeGreenOffset = 0x51
    private static let strokeBlueOffset = 0x55
    private static let strokeAlphaOffset = 0x59
    private static let strokePresetOffset = 0x64

    private static let penWidthOffset = 0x69

    private static let fillRedOffset = 0xA3
    private static let fillGreenOffset = 0xA7
    private static let fillBlueOffset = 0xAB
    private static let fillAlphaOffset = 0xAF
    private static let fillEnabledOffset = 0xB6
    private static let fillPresetOffset = 0xBA

    // MARK: - Test constants

    private static let recordLength = 389
    private static let storageScale = 10.0
    private static let accuracy = 0.000_001

    // MARK: - Geometry

    func testDecodesOriginalGeometry() throws {
        let roundedRectangle = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0
        )

        let anchor = try XCTUnwrap(
            roundedRectangle.anchor
        )

        XCTAssertEqual(
            anchor.x,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            50.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            130.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            90.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            10.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            10.0,
            accuracy: Self.accuracy
        )

        let penWidth = try XCTUnwrap(
            roundedRectangle.penWidth
        )

        XCTAssertEqual(
            penWidth,
            1.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesMovedGeometry() throws {
        let roundedRectangle = decodeRoundedRectangle(
            top: 60.0,
            left: 70.0,
            right: 150.0,
            bottom: 100.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0
        )

        let anchor = try XCTUnwrap(
            roundedRectangle.anchor
        )

        XCTAssertEqual(
            anchor.x,
            70.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            anchor.y,
            60.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            70.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            60.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            150.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            10.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            10.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesResizedGeometry() throws {
        let roundedRectangle = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 150.0,
            bottom: 110.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.left,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.top,
            50.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.right,
            150.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.bottom,
            110.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.width,
            100.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            60.0,
            accuracy: Self.accuracy
        )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            20.0,
            accuracy: Self.accuracy
        )
    }

    func testDecodesChangedCornerRadius() throws {
        let roundedRectangle = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 40.0,
            cornerHeight: 40.0
        )

        let cornerWidth = try XCTUnwrap(
            roundedRectangle.cornerWidth
        )

        XCTAssertEqual(
            cornerWidth,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerHeight = try XCTUnwrap(
            roundedRectangle.cornerHeight
        )

        XCTAssertEqual(
            cornerHeight,
            40.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            20.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            20.0,
            accuracy: Self.accuracy
        )

        let bounds = try XCTUnwrap(
            roundedRectangle.bounds
        )

        XCTAssertEqual(
            bounds.width,
            80.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            bounds.height,
            40.0,
            accuracy: Self.accuracy
        )
    }

    func testSupportsDifferentHorizontalAndVerticalRadii()
        throws
    {
        let roundedRectangle = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 30.0,
            cornerHeight: 16.0
        )

        let cornerRadiusX = try XCTUnwrap(
            roundedRectangle.cornerRadiusX
        )

        XCTAssertEqual(
            cornerRadiusX,
            15.0,
            accuracy: Self.accuracy
        )

        let cornerRadiusY = try XCTUnwrap(
            roundedRectangle.cornerRadiusY
        )

        XCTAssertEqual(
            cornerRadiusY,
            8.0,
            accuracy: Self.accuracy
        )
    }

    // MARK: - Style

    func testDecodesSharedObjectStyle() throws {
        let roundedRectangle = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            penWidth: 2.5,
            strokeColor: TestColor(
                red: 0.864927,
                green: 0.034211,
                blue: 0.025910,
                alpha: 1.0
            ),
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: TestColor(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 1.0
            ),
            fillPresetIndex: 2
        )

        try assertStyle(
            roundedRectangle.style,
            penWidth: 2.5,
            strokeColor: TestColor(
                red: 0.864927,
                green: 0.034211,
                blue: 0.025910,
                alpha: 1.0
            ),
            strokePresetIndex: 4,
            isFillEnabled: true,
            fillColor: TestColor(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 1.0
            ),
            fillPresetIndex: 2
        )
    }

    func testDecodesWhiteFillSeparatelyFromNoFill()
        throws
    {
        let filled = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            isFillEnabled: true,
            fillColor: .white,
            fillPresetIndex: 1
        )

        XCTAssertTrue(filled.isFillEnabled)
        XCTAssertEqual(filled.fillPresetIndex, 1)

        let filledColor = try XCTUnwrap(
            filled.fillColor
        )

        XCTAssertEqual(
            filledColor.red,
            1.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            filledColor.green,
            1.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            filledColor.blue,
            1.0,
            accuracy: Self.accuracy
        )

        XCTAssertEqual(
            filledColor.alpha,
            1.0,
            accuracy: Self.accuracy
        )

        let notFilled = decodeRoundedRectangle(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0,
            isFillEnabled: false,
            fillColor: .white,
            fillPresetIndex: 0
        )

        XCTAssertFalse(notFilled.isFillEnabled)
        XCTAssertEqual(notFilled.fillPresetIndex, 0)

        let storedColor = try XCTUnwrap(
            notFilled.fillColor
        )

        XCTAssertEqual(
            storedColor.red,
            1.0,
            accuracy: Self.accuracy
        )
    }

    // MARK: - Record handling

    func testPreservesRawRecord() {
        let record = makeRoundedRectangleRecord(
            top: 50.0,
            left: 50.0,
            right: 130.0,
            bottom: 90.0,
            cornerWidth: 20.0,
            cornerHeight: 20.0
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: makeHeader(
                    recordLength: record.count
                ),
                record: record
            )

        XCTAssertEqual(
            roundedRectangle.rawRecord,
            record
        )
    }

    func testTruncatedRecordProducesNilGeometryAndStyle() {
        let record = Data(
            repeating: 0,
            count: 8
        )

        let roundedRectangle =
            MD70RoundedRectangleDecoder.decode(
                header: makeHeader(
                    recordLength: record.count
                ),
                record: record
            )

        XCTAssertNil(roundedRectangle.anchor)
        XCTAssertNil(roundedRectangle.bounds)
        XCTAssertNil(roundedRectangle.cornerWidth)
        XCTAssertNil(roundedRectangle.cornerHeight)
        XCTAssertNil(roundedRectangle.cornerRadiusX)
        XCTAssertNil(roundedRectangle.cornerRadiusY)

        XCTAssertNil(roundedRectangle.penWidth)
        XCTAssertNil(roundedRectangle.strokeColor)
        XCTAssertNil(
            roundedRectangle.strokePresetIndex
        )

        XCTAssertFalse(
            roundedRectangle.isFillEnabled
        )

        XCTAssertNil(roundedRectangle.fillColor)
        XCTAssertNil(
            roundedRectangle.fillPresetIndex
        )

        XCTAssertEqual(
            roundedRectangle.rawRecord,
            record
        )
    }

    // MARK: - Decode helper

    private func decodeRoundedRectangle(
        top: Double,
        left: Double,
        right: Double,
        bottom: Double,
        cornerWidth: Double,
        cornerHeight: Double,
        penWidth: Double = 1.0,
        strokeColor: TestColor = .black,
        strokePresetIndex: UInt8 = 2,
        isFillEnabled: Bool = false,
        fillColor: TestColor = .white,
        fillPresetIndex: UInt8 = 0
    ) -> MD70RoundedRectangle {
        let record = makeRoundedRectangleRecord(
            top: top,
            left: left,
            right: right,
            bottom: bottom,
            cornerWidth: cornerWidth,
            cornerHeight: cornerHeight,
            penWidth: penWidth,
            strokeColor: strokeColor,
            strokePresetIndex: strokePresetIndex,
            isFillEnabled: isFillEnabled,
            fillColor: fillColor,
            fillPresetIndex: fillPresetIndex
        )

        return MD70RoundedRectangleDecoder.decode(
            header: makeHeader(
                recordLength: record.count
            ),
            record: record
        )
    }

    // MARK: - Record fixture

    private func makeRoundedRectangleRecord(
        top: Double,
        left: Double,
        right: Double,
        bottom: Double,
        cornerWidth: Double,
        cornerHeight: Double,
        penWidth: Double = 1.0,
        strokeColor: TestColor = .black,
        strokePresetIndex: UInt8 = 2,
        isFillEnabled: Bool = false,
        fillColor: TestColor = .white,
        fillPresetIndex: UInt8 = 0
    ) -> Data {
        var record = Data(
            repeating: 0,
            count: Self.recordLength
        )

        writeScaledFloat64BE(
            top,
            to: &record,
            at: Self.topOffset
        )

        writeScaledFloat64BE(
            left,
            to: &record,
            at: Self.leftOffset
        )

        writeColor(
            strokeColor,
            to: &record,
            redOffset: Self.strokeRedOffset,
            greenOffset: Self.strokeGreenOffset,
            blueOffset: Self.strokeBlueOffset,
            alphaOffset: Self.strokeAlphaOffset
        )

        writeUInt8(
            strokePresetIndex,
            to: &record,
            at: Self.strokePresetOffset
        )

        writeFloat64BE(
            penWidth,
            to: &record,
            at: Self.penWidthOffset
        )

        writeColor(
            fillColor,
            to: &record,
            redOffset: Self.fillRedOffset,
            greenOffset: Self.fillGreenOffset,
            blueOffset: Self.fillBlueOffset,
            alphaOffset: Self.fillAlphaOffset
        )

        writeUInt8(
            isFillEnabled ? 1 : 0,
            to: &record,
            at: Self.fillEnabledOffset
        )

        writeUInt8(
            fillPresetIndex,
            to: &record,
            at: Self.fillPresetOffset
        )

        writeScaledFloat64BE(
            right,
            to: &record,
            at: Self.rightOffset
        )

        writeScaledFloat64BE(
            bottom,
            to: &record,
            at: Self.bottomOffset
        )

        writeScaledFloat64BE(
            cornerWidth,
            to: &record,
            at: Self.cornerWidthOffset
        )

        writeScaledFloat64BE(
            cornerHeight,
            to: &record,
            at: Self.cornerHeightOffset
        )

        return record
    }

    // MARK: - Assertions

    private func assertStyle(
        _ style: MD70ObjectStyle,
        penWidth: Double,
        strokeColor: TestColor,
        strokePresetIndex: UInt8,
        isFillEnabled: Bool,
        fillColor: TestColor,
        fillPresetIndex: UInt8
    ) throws {
        let decodedPenWidth = try XCTUnwrap(
            style.penWidth
        )

        XCTAssertEqual(
            decodedPenWidth,
            penWidth,
            accuracy: Self.accuracy
        )

        let decodedStrokeColor = try XCTUnwrap(
            style.strokeColor
        )

        assertColor(
            decodedStrokeColor,
            equals: strokeColor
        )

        XCTAssertEqual(
            style.strokePresetIndex,
            strokePresetIndex
        )

        XCTAssertEqual(
            style.isFillEnabled,
            isFillEnabled
        )

        let decodedFillColor = try XCTUnwrap(
            style.fillColor
        )

        assertColor(
            decodedFillColor,
            equals: fillColor
        )

        XCTAssertEqual(
            style.fillPresetIndex,
            fillPresetIndex
        )
    }

    private func assertColor(
        _ actual: MD70Color,
        equals expected: TestColor,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            actual.red,
            expected.red,
            accuracy: Self.accuracy,
            file: file,
            line: line
        )

        XCTAssertEqual(
            actual.green,
            expected.green,
            accuracy: Self.accuracy,
            file: file,
            line: line
        )

        XCTAssertEqual(
            actual.blue,
            expected.blue,
            accuracy: Self.accuracy,
            file: file,
            line: line
        )

        XCTAssertEqual(
            actual.alpha,
            expected.alpha,
            accuracy: Self.accuracy,
            file: file,
            line: line
        )
    }

    // MARK: - Header

    private func makeHeader(
        recordLength: Int
    ) -> MD70ObjectHeader {
        MD70ObjectHeader(
            offset: 0,
            rawTypeCode: 0,
            type: .roundedRectangle,
            storedLength: UInt32(
                max(0, recordLength - 12)
            )
        )
    }

    // MARK: - Binary writers

    private func writeColor(
        _ color: TestColor,
        to data: inout Data,
        redOffset: Int,
        greenOffset: Int,
        blueOffset: Int,
        alphaOffset: Int
    ) {
        writeFloat32BE(
            Float(color.red),
            to: &data,
            at: redOffset
        )

        writeFloat32BE(
            Float(color.green),
            to: &data,
            at: greenOffset
        )

        writeFloat32BE(
            Float(color.blue),
            to: &data,
            at: blueOffset
        )

        writeFloat32BE(
            Float(color.alpha),
            to: &data,
            at: alphaOffset
        )
    }

    private func writeUInt8(
        _ value: UInt8,
        to data: inout Data,
        at offset: Int
    ) {
        data[offset] = value
    }

    private func writeScaledFloat64BE(
        _ value: Double,
        to data: inout Data,
        at offset: Int
    ) {
        writeFloat64BE(
            value * Self.storageScale,
            to: &data,
            at: offset
        )
    }

    private func writeFloat32BE(
        _ value: Float,
        to data: inout Data,
        at offset: Int
    ) {
        let bits = value.bitPattern.bigEndian

        withUnsafeBytes(of: bits) { bytes in
            data.replaceSubrange(
                offset..<(offset + MemoryLayout<UInt32>.size),
                with: bytes
            )
        }
    }

    private func writeFloat64BE(
        _ value: Double,
        to data: inout Data,
        at offset: Int
    ) {
        let bits = value.bitPattern.bigEndian

        withUnsafeBytes(of: bits) { bytes in
            data.replaceSubrange(
                offset..<(offset + MemoryLayout<UInt64>.size),
                with: bytes
            )
        }
    }
}

// MARK: - Test-only color fixture

private struct TestColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    static let black = TestColor(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 1
    )

    static let white = TestColor(
        red: 1,
        green: 1,
        blue: 1,
        alpha: 1
    )
}
