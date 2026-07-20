import Foundation

enum MD70PolygonDecoder {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let penWidthOffset = 0x69

    private static let vertexCountOffset = 0xCC
    private static let vertexTableOffset = 0xD0
    private static let vertexStride = 0x20

    private static let vertexYOffset = 0x00
    private static let vertexXOffset = 0x08

    private static let storageScale = 10.0
    
    private static let fillRedOffset = 0xA3
    private static let fillGreenOffset = 0xA7
    private static let fillBlueOffset = 0xAB
    private static let fillAlphaOffset = 0xAF
    private static let fillEnabledOffset = 0xB6
    private static let fillPresetIndexOffset = 0xBA

    private static let strokeRedOffset = 0x4D
    private static let strokeGreenOffset = 0x51
    private static let strokeBlueOffset = 0x55
    private static let strokeAlphaOffset = 0x59
    private static let strokePresetIndexOffset = 0x64
    
    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70Polygon {
        let reader = MD70BinaryReader(data: record)

        let storedAnchorY = reader.float64BE(
            at: anchorTopOffset
        ).map {
            $0 / storageScale
        }

        let storedAnchorX = reader.float64BE(
            at: anchorLeftOffset
        ).map {
            $0 / storageScale
        }

        let storedAnchor: MD70Point?
        if
            let storedAnchorX,
            let storedAnchorY
        {
            storedAnchor = MD70Point(
                x: storedAnchorX,
                y: storedAnchorY
            )
        } else {
            storedAnchor = nil
        }

        let vertexCount = reader.uint32BE(
            at: vertexCountOffset
        ).map(Int.init) ?? 0

        var vertices: [MD70Point] = []
        vertices.reserveCapacity(vertexCount)

        for index in 0..<vertexCount {
            let vertexOffset =
                vertexTableOffset +
                index * vertexStride

            guard
                let storedY = reader.float64BE(
                    at: vertexOffset + vertexYOffset
                ),
                let storedX = reader.float64BE(
                    at: vertexOffset + vertexXOffset
                )
            else {
                break
            }

            vertices.append(
                MD70Point(
                    x: storedX / storageScale,
                    y: storedY / storageScale
                )
            )
        }

        /*
         The verified hexagons store the final vertex at the same
         coordinate as the object-level anchor. Prefer the decoded
         vertex because it comes from the authoritative vertex table,
         while retaining the object-level value as a fallback for
         truncated or malformed records.
         */
        let anchor = vertices.last ?? storedAnchor

        /*
        let fillColor: MD70Color?
        let strokeColor: MD70Color?

        if
            let red = reader.float32BE(at: fillRedOffset),
            let green = reader.float32BE(at: fillGreenOffset),
            let blue = reader.float32BE(at: fillBlueOffset),
            let alpha = reader.float32BE(at: fillAlphaOffset)
        {
            fillColor = MD70Color(
                red: Double(red),
                green: Double(green),
                blue: Double(blue),
                alpha: Double(alpha)
            )
        } else {
            fillColor = nil
        }
        
        

        if
            let red = reader.float32BE(
                at: strokeRedOffset
            ),
            let green = reader.float32BE(
                at: strokeGreenOffset
            ),
            let blue = reader.float32BE(
                at: strokeBlueOffset
            ),
            let alpha = reader.float32BE(
                at: strokeAlphaOffset
            )
        {
            strokeColor = MD70Color(
                red: Double(red),
                green: Double(green),
                blue: Double(blue),
                alpha: Double(alpha)
            )
        } else {
            strokeColor = nil
        }
        */
        
        let style = MD70ObjectStyleDecoder.decode(
            from: reader
        )

        return MD70Polygon(
            header: header,
            anchor: anchor,
            vertices: vertices,
            style: style,
            rawRecord: record
        )
    }
}
