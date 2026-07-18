import Foundation
import MacDraftKit

@main
struct MacDraftInfoCommand {
    static func main() {
        do {
            let options = try parseArguments()
            let document = try MacDraftDocument(contentsOf: options.input)

            print("Format: \(document.formatIdentifier)")
            if let pdf = document.embeddedPDF {
                print("Embedded PDF: yes")
                print("PDF offset: \(pdf.offset)")
                print("PDF length: \(pdf.length)")
            } else {
                print("Embedded PDF: no")
            }

            if let objectSection = document.objectSection {
                print()
                print("Objects: \(objectSection.declaredObjectCount)")

                for (index, object) in objectSection.objects.enumerated() {
                    print()
                    let typeName = object.type?.displayName
                        ?? "Unknown type 0x\(String(object.rawTypeCode, radix: 16, uppercase: true))"
                    print("Object #\(index + 1) (\(typeName))")
                    print("------------------------")
                    print("Offset: 0x\(String(object.offset, radix: 16, uppercase: true))")
                    print("Center: \(format(object.centerX)), \(format(object.centerY)) pt")
                    print("Size: \(format(object.width)) × \(format(object.height)) pt")
                    print("Pen width: \(format(object.penWidth)) pt")
                }

                let undecodedCount =
                    objectSection.declaredObjectCount - objectSection.objects.count
                if undecodedCount > 0 {
                    print()
                    print("\(undecodedCount) object record(s) could not be decoded.")
                }
            }

            if let hexRange = options.hexRange {
                let data = try Data(contentsOf: options.input)
                let dump = try HexDump(data: data)

                print()
                print("Hex dump (offset \(hexRange.offset), count \(hexRange.count))")
                print("----------------------------------------")
                print(try dump.string(from: hexRange.offset, count: hexRange.count))
            }

            if options.shouldProbe {
                let data = try Data(contentsOf: options.input)
                printProbeReport(try DocumentProbe(data: data).run())
            }
        } catch {
            FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static func parseArguments() throws -> Options {
        let arguments = Array(CommandLine.arguments.dropFirst())

        switch arguments.count {
        case 1:
            return Options(
                input: URL(fileURLWithPath: arguments[0]),
                hexRange: nil,
                shouldProbe: false
            )

        case 2 where arguments[1] == "--probe":
            return Options(
                input: URL(fileURLWithPath: arguments[0]),
                hexRange: nil,
                shouldProbe: true
            )

        case 4 where arguments[1] == "--hex":
            return Options(
                input: URL(fileURLWithPath: arguments[0]),
                hexRange: HexRange(
                    offset: try parseInteger(arguments[2], name: "offset"),
                    count: try parseInteger(arguments[3], name: "count")
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

    private static func printProbeReport(_ report: DocumentProbe.Report) {
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
                    "  0x\(String(match.offset, radix: 16, uppercase: true)): " +
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
                    "  0x\(String(string.offset, radix: 16, uppercase: true)): " +
                    string.value
                )
            }
        }
    }

    private static func format(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(value)
    }

    private static func parseInteger(_ value: String, name: String) throws -> Int {
        let parsed: Int?

        if value.lowercased().hasPrefix("0x") {
            parsed = Int(value.dropFirst(2), radix: 16)
        } else {
            parsed = Int(value)
        }

        guard let parsed, parsed >= 0 else {
            throw UsageError(
                message: "\(name) must be a non-negative decimal or hexadecimal integer"
            )
        }

        return parsed
    }
}

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
    var errorDescription: String? { message }
}
