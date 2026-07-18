import Foundation

public struct BinaryDiff: Sendable, Equatable {
    public struct Region: Sendable, Equatable {
        public enum Kind: String, Sendable {
            case equal
            case inserted
            case deleted
            case replaced
        }

        public let kind: Kind
        public let leftRange: Range<Int>
        public let rightRange: Range<Int>

        public init(kind: Kind, leftRange: Range<Int>, rightRange: Range<Int>) {
            self.kind = kind
            self.leftRange = leftRange
            self.rightRange = rightRange
        }
    }

    public let leftSize: Int
    public let rightSize: Int
    public let regions: [Region]

    public init(left: Data, right: Data, anchorLength: Int = 16, lookahead: Int = 4096) {
        precondition(anchorLength > 0)
        precondition(lookahead > 0)

        let leftBytes = Array(left)
        let rightBytes = Array(right)
        self.leftSize = leftBytes.count
        self.rightSize = rightBytes.count
        self.regions = Self.computeRegions(
            left: leftBytes,
            right: rightBytes,
            anchorLength: anchorLength,
            lookahead: lookahead
        )
    }

    private static func computeRegions(
        left: [UInt8],
        right: [UInt8],
        anchorLength: Int,
        lookahead: Int
    ) -> [Region] {
        var result: [Region] = []
        var leftIndex = 0
        var rightIndex = 0

        while leftIndex < left.count && rightIndex < right.count {
            let equalStartLeft = leftIndex
            let equalStartRight = rightIndex
            while leftIndex < left.count,
                  rightIndex < right.count,
                  left[leftIndex] == right[rightIndex] {
                leftIndex += 1
                rightIndex += 1
            }

            append(
                Region(kind: .equal,
                       leftRange: equalStartLeft..<leftIndex,
                       rightRange: equalStartRight..<rightIndex),
                to: &result
            )

            guard leftIndex < left.count, rightIndex < right.count else { break }

            let mismatchLeft = leftIndex
            let mismatchRight = rightIndex

            if let match = nextAnchor(
                left: left,
                right: right,
                leftStart: leftIndex,
                rightStart: rightIndex,
                anchorLength: anchorLength,
                lookahead: lookahead
            ) {
                leftIndex = match.left
                rightIndex = match.right
            } else {
                leftIndex = left.count
                rightIndex = right.count
            }

            let leftRange = mismatchLeft..<leftIndex
            let rightRange = mismatchRight..<rightIndex
            let kind: Region.Kind
            if leftRange.isEmpty {
                kind = .inserted
            } else if rightRange.isEmpty {
                kind = .deleted
            } else {
                kind = .replaced
            }
            append(Region(kind: kind, leftRange: leftRange, rightRange: rightRange), to: &result)
        }

        if leftIndex < left.count || rightIndex < right.count {
            let leftRange = leftIndex..<left.count
            let rightRange = rightIndex..<right.count
            let kind: Region.Kind
            if leftRange.isEmpty {
                kind = .inserted
            } else if rightRange.isEmpty {
                kind = .deleted
            } else {
                kind = .replaced
            }
            append(Region(kind: kind, leftRange: leftRange, rightRange: rightRange), to: &result)
        }

        return result
    }

    private static func nextAnchor(
        left: [UInt8],
        right: [UInt8],
        leftStart: Int,
        rightStart: Int,
        anchorLength: Int,
        lookahead: Int
    ) -> (left: Int, right: Int)? {
        guard leftStart + anchorLength <= left.count,
              rightStart + anchorLength <= right.count else { return nil }

        let leftLimit = min(left.count - anchorLength, leftStart + lookahead)
        let rightLimit = min(right.count - anchorLength, rightStart + lookahead)

        var rightAnchors: [ArraySlice<UInt8>: Int] = [:]
        if rightStart <= rightLimit {
            for index in rightStart...rightLimit {
                let anchor = right[index..<(index + anchorLength)]
                rightAnchors[anchor, default: index] = min(rightAnchors[anchor] ?? index, index)
            }
        }

        var best: (left: Int, right: Int, cost: Int)?
        if leftStart <= leftLimit {
            for index in leftStart...leftLimit {
                let anchor = left[index..<(index + anchorLength)]
                guard let rightIndex = rightAnchors[anchor] else { continue }
                let cost = (index - leftStart) + (rightIndex - rightStart)
                if best == nil || cost < best!.cost {
                    best = (index, rightIndex, cost)
                }
            }
        }
        return best.map { ($0.left, $0.right) }
    }

    private static func append(_ region: Region, to regions: inout [Region]) {
        guard !region.leftRange.isEmpty || !region.rightRange.isEmpty else { return }
        if let last = regions.last,
           last.kind == region.kind,
           last.leftRange.upperBound == region.leftRange.lowerBound,
           last.rightRange.upperBound == region.rightRange.lowerBound {
            regions[regions.count - 1] = Region(
                kind: region.kind,
                leftRange: last.leftRange.lowerBound..<region.leftRange.upperBound,
                rightRange: last.rightRange.lowerBound..<region.rightRange.upperBound
            )
        } else {
            regions.append(region)
        }
    }
}
