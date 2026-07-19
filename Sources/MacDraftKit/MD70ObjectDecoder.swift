import Foundation

enum MD70ObjectDecoder {
    private static let anchorTopOffset = 0x09
    private static let anchorLeftOffset = 0x11
    private static let penWidthOffset = 0x69
    private static let storageScale = 10.0

    static func decode(
        header: MD70ObjectHeader,
        record: Data
    ) -> any MD70DrawingObject {
        switch header.type {
        case .rectangle:
            return MD70RectangleDecoder.decode(
                header: header,
                record: record
            )

        case .text:
            return MD70TextDecoder.decode(
                header: header,
                record: record
            )
            
        case .ellipse:
            return MD70EllipseDecoder.decode(
                header: header,
                record: record
            )
        
        case .line:
            return MD70LineDecoder.decode(
                header: header,
                record: record
            )
            
        default:
            return decodeUnknown(
                header: header,
                record: record
            )
        }
    }

    private static func decodeUnknown(
        header: MD70ObjectHeader,
        record: Data
    ) -> MD70UnknownObject {
        let reader = MD70BinaryReader(data: record)

        if header.type == .line {
            if let duplicateVertical = reader.float64BE(at: 0xAD) {
                print(
                    "Duplicate start vertical: " +
                    "\(duplicateVertical / storageScale) pt"
                )
            }

            if let duplicateHorizontal = reader.float64BE(at: 0xB5) {
                print(
                    "Duplicate start horizontal: " +
                    "\(duplicateHorizontal / storageScale) pt"
                )
            }

            if let secondVertical = reader.float64BE(at: 0xCD) {
                print(
                    "Candidate end vertical: " +
                    "\(secondVertical / storageScale) pt"
                )
            }

            if let secondHorizontal = reader.float64BE(at: 0xD5) {
                print(
                    "Candidate end horizontal: " +
                    "\(secondHorizontal / storageScale) pt"
                )
            }
        }
        
        /*
        if header.type == .ellipse {
            if let secondVertical = reader.float64BE(at: 0xCB) {
                print(
                    "Candidate second vertical: " +
                    "\(secondVertical / storageScale) pt"
                )
            }

            if let secondHorizontal = reader.float64BE(at: 0xD3) {
                print(
                    "Candidate second horizontal: " +
                    "\(secondHorizontal / storageScale) pt"
                )
            }
        }
        */
        
        let top = reader.float64BE(at: anchorTopOffset).map {
            $0 / storageScale
        }

        let left = reader.float64BE(at: anchorLeftOffset).map {
            $0 / storageScale
        }

        let anchor: MD70Point?
        if let left, let top {
            anchor = MD70Point(x: left, y: top)
        } else {
            anchor = nil
        }

        return MD70UnknownObject(
            header: header,
            anchor: anchor,
            penWidth: reader.float64BE(at: penWidthOffset),
            rawRecord: record
        )
    }
}
