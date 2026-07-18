import Foundation
import MacDraftKit

@main
struct MacDraftDiffCommand {
    static func main() {
        do {
            let arguments = CommandLine.arguments
            if arguments.count == 4, arguments[1] == "--dump" {
                try dump(file: arguments[2], rangeExpression: arguments[3])
                return
            }
            guard arguments.count == 3 else {
                throw UsageError(message: usage)
            }
            try compare(leftPath: arguments[1], rightPath: arguments[2])
        } catch {
            FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static let usage = """
    usage:
      macdraftdiff <left.md70> <right.md70>
      macdraftdiff --dump <document.md70> <start:end>

    offsets may be decimal or hexadecimal, for example 0x50F0:0x5400
    """

    private static func compare(leftPath: String, rightPath: String) throws {
        let leftURL = URL(fileURLWithPath: leftPath)
        let rightURL = URL(fileURLWithPath: rightPath)
        let left = try Data(contentsOf: leftURL, options: .mappedIfSafe)
        let right = try Data(contentsOf: rightURL, options: .mappedIfSafe)
        let diff = BinaryDiff(left: left, right: right)
        print("Left:  \(leftURL.lastPathComponent) (\(diff.leftSize) bytes)")
        print("Right: \(rightURL.lastPathComponent) (\(diff.rightSize) bytes)")
        print("\nRegions\n-------")
        for region in diff.regions { print(format(region)) }
    }

    private static func dump(file: String, rangeExpression: String) throws {
        let url = URL(fileURLWithPath: file)
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let range = try parseRange(rangeExpression)
        let dump = try BinaryRangeDump(data: data, range: range)
        print("File:  \(url.lastPathComponent) (\(data.count) bytes)")
        print(String(format: "Range: 0x%08X–0x%08X (%d bytes)\n", range.lowerBound, range.upperBound - 1, range.count))
        print(dump.render(data: data))
    }

    private static func parseRange(_ expression: String) throws -> Range<Int> {
        let parts = expression.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let start = parseInteger(String(parts[0])),
              let end = parseInteger(String(parts[1])),
              start >= 0, end >= start else { throw UsageError(message: usage) }
        return start..<end
    }

    private static func parseInteger(_ value: String) -> Int? {
        if value.lowercased().hasPrefix("0x") { return Int(value.dropFirst(2), radix: 16) }
        return Int(value)
    }

    private static func format(_ region: BinaryDiff.Region) -> String {
        let label = region.kind.rawValue.capitalized.padding(toLength: 9, withPad: " ", startingAt: 0)
        return "\(label) left \(format(region.leftRange))  right \(format(region.rightRange))"
    }

    private static func format(_ range: Range<Int>) -> String {
        if range.isEmpty { return "—" }
        return String(format: "0x%08X–0x%08X (%d bytes)", range.lowerBound, range.upperBound - 1, range.count)
    }
}

private struct UsageError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
