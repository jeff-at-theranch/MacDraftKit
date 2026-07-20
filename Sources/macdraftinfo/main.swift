import Foundation
import MacDraftKit

@main
struct MacDraftInfoCommand {
    static func main() {
        do {
            let options = try parseArguments()
            let document = try MacDraftDocument(
                contentsOf: options.input
            )

            printDocumentSummary(document)
            printObjectSection(document.objectSection)

            if let hexRange = options.hexRange {
                try printHexDump(
                    input: options.input,
                    range: hexRange
                )
            }

            if options.shouldProbe {
                let data = try Data(
                    contentsOf: options.input
                )

                printProbeReport(
                    try DocumentProbe(data: data).run()
                )
            }
        } catch {
            FileHandle.standardError.write(
                Data(
                    "error: \(error.localizedDescription)\n".utf8
                )
            )

            Foundation.exit(EXIT_FAILURE)
        }
    }

    // MARK: - Document

    private static func printDocumentSummary(
        _ document: MacDraftDocument
    ) {
        print("Format: \(document.formatIdentifier)")

        guard let pdf = document.embeddedPDF else {
            print("Embedded PDF: no")
            return
        }

        print("Embedded PDF: yes")
        print("PDF offset: \(pdf.offset)")
        print("PDF length: \(pdf.length)")
    }

    // MARK: - Objects

    private static func printObjectSection(
        _ section: MD70ObjectSection?
    ) {
        guard let section else {
            print()
            print("Object section: unavailable")
            return
        }

        print()
        print("Objects: \(section.declaredObjectCount)")

        for (index, object) in section.objects.enumerated() {
            print()
            printObject(
                object,
                number: index + 1
            )
        }

        let undecodedCount =
            section.declaredObjectCount -
            section.objects.count

        if undecodedCount > 0 {
            print()
            print(
                "\(undecodedCount) object record(s) " +
                "could not be traversed."
            )
        }
    }

    private static func printObject(
        _ object: any MD70DrawingObject,
        number: Int
    ) {
        let typeName =
            object.type?.displayName ??
            unknownTypeName(object.rawTypeCode)

        print("Object #\(number) (\(typeName))")
        print("------------------------")

        print(
            "Offset: " +
            HexFormatter.string(object.offset)
        )

        print(
            "Stored length: " +
            "\(object.storedLength) bytes"
        )

        print(
            "Total length: " +
            "\(object.totalLength) bytes"
        )

        printAnchor(object.anchor)
        printBounds(object.bounds)
        printObjectSpecificDetails(object)
        printObjectStyle(object)
    }

    private static func printAnchor(
        _ anchor: MD70Point?
    ) {
        guard let anchor else {
            print("Anchor: not decoded")
            return
        }

        print(
            "Anchor: " +
            "\(NumberFormatter.coordinate(anchor.x)), " +
            "\(NumberFormatter.coordinate(anchor.y)) pt"
        )
    }

    private static func printBounds(
        _ bounds: MD70Bounds?
    ) {
        guard let bounds else {
            print(
                "Geometry: object-specific bounds " +
                "not yet decoded"
            )
            return
        }

        print("Bounds:")
        printMeasurement("Left", bounds.left)
        printMeasurement("Top", bounds.top)
        printMeasurement("Right", bounds.right)
        printMeasurement("Bottom", bounds.bottom)

        print(
            "  Size: " +
            "\(NumberFormatter.coordinate(bounds.width)) × " +
            "\(NumberFormatter.coordinate(bounds.height)) pt"
        )
    }

    private static func printObjectSpecificDetails(
        _ object: any MD70DrawingObject
    ) {
        switch object {
        case let text as MD70Text:
            printTextDetails(text)

        case let circle as MD70Circle:
            printCircleDetails(circle)

        case let roundedRectangle as MD70RoundedRectangle:
            printRoundedRectangleDetails(
                roundedRectangle
            )

        case let polygon as MD70Polygon:
            printPolygonDetails(polygon)

        case let parameters as MD70PolygonParameters:
            printPolygonParameterDetails(parameters)
            
        case let bezier as MD70Bezier:
            printBezierDetails(bezier)
            
        default:
            break
        }
    }

    // MARK: - Text

    private static func printTextDetails(
        _ text: MD70Text
    ) {
        guard !text.rtfData.isEmpty else {
            print("Embedded RTF: not found")
            return
        }

        print("Embedded RTF: yes")
        print("RTF length: \(text.rtfData.count) bytes")

        let prefixData = text.rtfData.prefix(40)
        let prefix = String(
            decoding: prefixData,
            as: UTF8.self
        )

        print("RTF prefix: \(prefix)")
    }

    // MARK: - Circle

    private static func printCircleDetails(
        _ circle: MD70Circle
    ) {
        if let center = circle.center {
            print(
                "Center: " +
                "\(NumberFormatter.coordinate(center.x)), " +
                "\(NumberFormatter.coordinate(center.y)) pt"
            )
        }

        printOptionalMeasurement(
            "Radius",
            circle.radius
        )

        printOptionalMeasurement(
            "Diameter",
            circle.diameter
        )
    }

    // MARK: - Rounded rectangle

    private static func printRoundedRectangleDetails(
        _ roundedRectangle: MD70RoundedRectangle
    ) {
        printOptionalMeasurement(
            "Corner width",
            roundedRectangle.cornerWidth
        )

        printOptionalMeasurement(
            "Corner height",
            roundedRectangle.cornerHeight
        )

        printOptionalMeasurement(
            "Corner radius X",
            roundedRectangle.cornerRadiusX
        )

        printOptionalMeasurement(
            "Corner radius Y",
            roundedRectangle.cornerRadiusY
        )
    }

    // MARK: - Polygon

    private static func printPolygonDetails(
        _ polygon: MD70Polygon
    ) {
        print("Polygon:")
        print("  Shape: \(polygon.shapeName)")
        print("  Vertex count: \(polygon.vertices.count)")

        if let orientation =
            polygon.firstVertexAngleDegrees
        {
            print(
                "  Orientation: " +
                "\(NumberFormatter.coordinate(orientation))° " +
                "clockwise from right"
            )
        }

        for (index, vertex) in
            polygon.vertices.enumerated()
        {
            print(
                "  Vertex \(index): " +
                PointFormatter.parenthesized(vertex)
            )
        }
    }

    private static func printPolygonParameterDetails(
        _ parameters: MD70PolygonParameters
    ) {
        print("Polygon parameters:")

        if let rotation = parameters.rotationDegrees {
            print(
                "  Rotation: " +
                "\(NumberFormatter.coordinate(rotation))°"
            )
        }
    }

    // MARK: - Style

    private static func printObjectStyle(
        _ object: any MD70DrawingObject
    ) {
        if let styledObject =
            object as? any CLIStyledObject
        {
            printStyle(styledObject.style)
            return
        }

        // Retain support for objects such as lines that expose only
        // the common penWidth property.
        if let penWidth = object.penWidth {
            printMeasurement(
                "Pen width",
                penWidth
            )
        }
    }

    private static func printBezierDetails(
        _ bezier: MD70Bezier
    ) {
        print("Bezier:")
        print("  Point count: \(bezier.points.count)")
        print("  Segment count: \(bezier.segments.count)")
        print("  Closed: \(bezier.isClosed ? "yes" : "no")")

        for (index, segment) in bezier.segments.enumerated() {
            print("  Segment \(index):")

            print(
                "    Start: " +
                PointFormatter.parenthesized(segment.start)
            )

            print(
                "    Control 1: " +
                PointFormatter.parenthesized(segment.control1)
            )

            print(
                "    Control 2: " +
                PointFormatter.parenthesized(segment.control2)
            )

            print(
                "    End: " +
                PointFormatter.parenthesized(segment.end)
            )

            print(
                "    Outgoing handle length: " +
                "\(NumberFormatter.coordinate(segment.outgoingHandle.length)) pt"
            )

            print(
                "    Outgoing handle angle: " +
                "\(NumberFormatter.coordinate(segment.outgoingHandle.angleDegrees))°"
            )

            print(
                "    Incoming handle length: " +
                "\(NumberFormatter.coordinate(segment.incomingHandle.length)) pt"
            )

            print(
                "    Incoming handle angle: " +
                "\(NumberFormatter.coordinate(segment.incomingHandle.angleDegrees))°"
            )
            
            let outgoing = segment.outgoingHandle

            print(
                "    Outgoing handle: " +
                (outgoing.isCollapsed() ? "collapsed" : "active")
            )

            print(
                "    Outgoing handle length: " +
                "\(NumberFormatter.coordinate(outgoing.length)) pt"
            )

            if outgoing.isActive() {
                print(
                    "    Outgoing handle angle: " +
                    "\(NumberFormatter.coordinate(outgoing.angleDegrees))°"
                )
            }
            
            let incoming = segment.incomingHandle

            print(
                "    Incoming handle: " +
                (incoming.isCollapsed() ? "collapsed" : "active")
            )

            print(
                "    Incoming handle length: " +
                "\(NumberFormatter.coordinate(incoming.length)) pt"
            )

            if incoming.isActive() {
                print(
                    "    Incoming handle angle: " +
                    "\(NumberFormatter.coordinate(incoming.angleDegrees))°"
                )
            }
        }
    }
    
    private static func printStyle(
        _ style: MD70ObjectStyle
    ) {
        if let strokeColor = style.strokeColor {
            printColor(
                "Stroke RGBA",
                strokeColor
            )
        }

        if let preset = style.strokePresetIndex {
            print("Stroke preset: \(preset)")
        }

        if let penWidth = style.penWidth {
            printMeasurement(
                "Pen width",
                penWidth
            )
        }

        print(
            "Fill: " +
            (style.isFillEnabled ? "enabled" : "none")
        )

        if let fillColor = style.fillColor {
            printColor(
                "Fill RGBA",
                fillColor
            )
        }

        if let preset = style.fillPresetIndex {
            print("Fill preset: \(preset)")
        }
    }

    private static func printColor(
        _ label: String,
        _ color: MD70Color
    ) {
        print(
            "\(label): " +
            "\(NumberFormatter.color(color.red)), " +
            "\(NumberFormatter.color(color.green)), " +
            "\(NumberFormatter.color(color.blue)), " +
            "\(NumberFormatter.color(color.alpha))"
        )
    }

    // MARK: - Shared output helpers

    private static func printMeasurement(
        _ label: String,
        _ value: Double
    ) {
        print(
            "\(label): " +
            "\(NumberFormatter.coordinate(value)) pt"
        )
    }

    private static func printOptionalMeasurement(
        _ label: String,
        _ value: Double?
    ) {
        guard let value else {
            return
        }

        printMeasurement(label, value)
    }

    private static func unknownTypeName(
        _ rawTypeCode: UInt8
    ) -> String {
        "Unknown type " +
        HexFormatter.string(
            Int(rawTypeCode),
            minimumDigits: 2
        )
    }

    // MARK: - Hex dump

    private static func printHexDump(
        input: URL,
        range: HexRange
    ) throws {
        let data = try Data(contentsOf: input)
        let dump = try HexDump(data: data)

        print()
        print(
            "Hex dump " +
            "(offset \(range.offset), count \(range.count))"
        )
        print("----------------------------------------")

        print(
            try dump.string(
                from: range.offset,
                count: range.count
            )
        )
    }

    // MARK: - Probe

    private static func printProbeReport(
        _ report: DocumentProbe.Report
    ) {
        print()
        print("Binary probe")
        print("------------")
        print("File size: \(report.fileSize) bytes")

        print()
        print("Known signatures:")

        if report.signatures.isEmpty {
            print("  none")
        } else {
            for match in report.signatures {
                print(
                    "  \(HexFormatter.string(match.offset)): " +
                    match.kind.rawValue
                )
            }
        }

        print()
        print("ASCII strings:")

        if report.asciiStrings.isEmpty {
            print("  none")
        } else {
            for string in report.asciiStrings {
                print(
                    "  \(HexFormatter.string(string.offset)): " +
                    string.value
                )
            }
        }
    }

    // MARK: - Arguments

    private static func parseArguments() throws -> Options {
        let arguments = Array(
            CommandLine.arguments.dropFirst()
        )

        switch arguments.count {
        case 1:
            return Options(
                input: URL(
                    fileURLWithPath: arguments[0]
                ),
                hexRange: nil,
                shouldProbe: false
            )

        case 2 where arguments[1] == "--probe":
            return Options(
                input: URL(
                    fileURLWithPath: arguments[0]
                ),
                hexRange: nil,
                shouldProbe: true
            )

        case 4 where arguments[1] == "--hex":
            return Options(
                input: URL(
                    fileURLWithPath: arguments[0]
                ),
                hexRange: HexRange(
                    offset: try parseInteger(
                        arguments[2],
                        name: "offset"
                    ),
                    count: try parseInteger(
                        arguments[3],
                        name: "count"
                    )
                ),
                shouldProbe: false
            )

        default:
            throw UsageError(
                message: """
                usage: macdraftinfo <document.md70> [--probe]
                       macdraftinfo <document.md70> --hex <offset> <count>
                """
            )
        }
    }

    private static func parseInteger(
        _ value: String,
        name: String
    ) throws -> Int {
        let parsed: Int?

        if value.lowercased().hasPrefix("0x") {
            parsed = Int(
                value.dropFirst(2),
                radix: 16
            )
        } else {
            parsed = Int(value)
        }

        guard let parsed, parsed >= 0 else {
            throw UsageError(
                message:
                    "\(name) must be a non-negative " +
                    "decimal or hexadecimal integer"
            )
        }

        return parsed
    }
}

// MARK: - CLI style adaptation

private protocol CLIStyledObject {
    var style: MD70ObjectStyle { get }
}

extension MD70Rectangle: CLIStyledObject {}
extension MD70RoundedRectangle: CLIStyledObject {}
extension MD70Circle: CLIStyledObject {}
extension MD70Polygon: CLIStyledObject {}
extension MD70Ellipse: CLIStyledObject {}
extension MD70Bezier: CLIStyledObject {}


// MARK: - Formatting

private enum NumberFormatter {
    static func coordinate(
        _ value: Double
    ) -> String {
        String(format: "%.6f", value)
    }

    static func color(
        _ value: Double
    ) -> String {
        String(format: "%.3f", value)
    }
}

private enum PointFormatter {
    static func parenthesized(
        _ point: MD70Point
    ) -> String {
        "(" +
        NumberFormatter.coordinate(point.x) +
        ", " +
        NumberFormatter.coordinate(point.y) +
        ")"
    }
}

private enum HexFormatter {
    static func string(
        _ value: Int,
        minimumDigits: Int = 0
    ) -> String {
        let digits = String(
            value,
            radix: 16,
            uppercase: true
        )

        let padding = String(
            repeating: "0",
            count: max(0, minimumDigits - digits.count)
        )

        return "0x\(padding)\(digits)"
    }
}

// MARK: - Options

private struct Options {
    let input: URL
    let hexRange: HexRange?
    let shouldProbe: Bool
}

private struct HexRange {
    let offset: Int
    let count: Int
}

private struct UsageError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}
