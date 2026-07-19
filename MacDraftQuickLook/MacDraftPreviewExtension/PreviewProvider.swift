import Foundation
import QuickLookUI
import UniformTypeIdentifiers
import MacDraftKit

final class PreviewProvider:
    QLPreviewProvider,
    QLPreviewingController
{
    func providePreview(
        for request: QLFilePreviewRequest
    ) async throws -> QLPreviewReply {
        let fileURL = request.fileURL

        NSLog(
            "MacDraft PreviewProvider invoked for %@",
            fileURL.path
        )

        return QLPreviewReply(
            dataOfContentType: .pdf,
            contentSize: CGSize(
                width: 612,
                height: 792
            )
        ) { reply in
            NSLog(
                "MacDraft extracting embedded PDF from %@",
                fileURL.path
            )

            reply.title = fileURL
                .deletingPathExtension()
                .lastPathComponent

            let pdfData = try MD70PreviewExtractor.embeddedPDF(
                from: fileURL
            )

            NSLog(
                "MacDraft extracted %ld PDF bytes",
                pdfData.count
            )

            return pdfData
        }
    }
}
