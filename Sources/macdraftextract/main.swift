import Foundation
import MacDraftKit

@main
struct MacDraftExtractCommand {
    static func main() {
        do {
            let arguments = try Arguments.parse()
            let document = try MacDraftDocument(contentsOf: arguments.input)
            guard let pdf = document.embeddedPDF else {
                throw MacDraftError.embeddedPDFNotFound
            }
            try pdf.write(to: arguments.output)
            print(arguments.output.path)
        } catch {
            FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

private struct Arguments {
    let input: URL
    let output: URL

    static func parse() throws -> Arguments {
        guard CommandLine.arguments.count == 3 else {
            throw UsageError(message: "usage: macdraftextract <document.md70> <output.pdf>")
        }
        return Arguments(
            input: URL(fileURLWithPath: CommandLine.arguments[1]),
            output: URL(fileURLWithPath: CommandLine.arguments[2])
        )
    }
}

private struct UsageError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
