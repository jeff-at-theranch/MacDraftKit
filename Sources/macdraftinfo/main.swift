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

            if let hexRange = options.hexRange {
                let data = try Data(contentsOf: options.input)
                let dump = try HexDump(data: data)

                print()
                print("Hex dump (offset \(hexRange.offset), count \(hexRange.count))")
                print("----------------------------------------")
                print(try dump.string(from: hexRange.offset, count: hexRange.count))
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
                hexRange: nil
            )

        case 4 where arguments[1] == "--hex":
            return Options(
                input: URL(fileURLWithPath: arguments[0]),
                hexRange: HexRange(
                    offset: try parseInteger(arguments[2], name: "offset"),
                    count: try parseInteger(arguments[3], name: "count")
                )
            )

        default:
            throw UsageError(
                message: "usage: macdraftinfo <document.md70> [--hex <offset> <count>]"
            )
        }
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
}

private struct HexRange {
    let offset: Int
    let count: Int
}

private struct UsageError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
