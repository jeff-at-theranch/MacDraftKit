import Foundation

enum MD70BezierDecoder {
    private static let pointCountOffset = 0xCC
    private static let pointTableOffset = 0xD0
    private static let pointStride = 0x20

    private static let pointYOffset = 0x00
    private static let pointXOffset = 0x08

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Bezier {
        let reader = MD70BinaryReader(data: record)

        let storedAnchor =
            MD70CommonObjectDecoder.decodeAnchor(
                from: reader
            )

        let pointCount =
            reader.uint32BE(
                at: pointCountOffset
            ).map(Int.init) ?? 0

        var points: [MD70Point] = []
        points.reserveCapacity(pointCount)

        for index in 0..<pointCount {
            let pointOffset =
                pointTableOffset +
                index * pointStride

            guard
                let point =
                    MD70CommonObjectDecoder.decodePoint(
                        from: reader,
                        yOffset:
                            pointOffset +
                            pointYOffset,
                        xOffset:
                            pointOffset +
                            pointXOffset
                    )
            else {
                break
            }

            points.append(point)
        }

        let anchor =
            points.first ??
            storedAnchor

        let segments = decodeSegments(
            from: points
        )

        return MD70Bezier(
            header: header,
            anchor: anchor,
            points: points,
            segments: segments,
            style:
                MD70ObjectStyleDecoder.decode(
                    from: reader
                ),
            rawRecord: record
        )
    }

    private static func decodeSegments(
        from points: [MD70Point]
    ) -> [MD70BezierSegment] {
        guard points.count >= 4 else {
            return []
        }

        let completeSegmentCount =
            (points.count - 1) / 3

        var segments: [MD70BezierSegment] = []
        segments.reserveCapacity(
            completeSegmentCount
        )

        for segmentIndex in
            0..<completeSegmentCount
        {
            let base = 1 + segmentIndex * 3

            let start: MD70Point

            if segmentIndex == 0 {
                start = points[0]
            } else {
                start = points[base - 1]
            }

            segments.append(
                MD70BezierSegment(
                    start: start,
                    control1: points[base],
                    control2: points[base + 1],
                    end: points[base + 2]
                )
            )
        }

        return segments
    }
}
