import Foundation
import MacDraftKit

@main
struct MacDraftInfoCommand {
    static func main() {
        do {
            let input = try inputURL()
            let document = try MacDraftDocument(contentsOf: input)

            print("Format: \(document.formatIdentifier)")
            if let pdf = document.embeddedPDF {
                print("Embedded PDF: yes")
                print("PDF offset: \(pdf.offset)")
                print("PDF length: \(pdf.length)")
            } else {
                print("Embedded PDF: no")
            }
        } catch {
            FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static func inputURL() throws -> URL {
        guard CommandLine.arguments.count == 2 else {
            throw UsageError(message: "usage: macdraftinfo <document.md70>")
        }
        return URL(fileURLWithPath: CommandLine.arguments[1])
    }
}

private struct UsageError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
