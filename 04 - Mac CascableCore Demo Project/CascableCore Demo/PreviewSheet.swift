import SwiftUI
import CascableCore

struct PreviewSheet: View {

    let transferRequest: CameraInitiatedTransferRequest

    private enum RequestState {
        case loading
        case loaded(result: NSImage)
        case failed(error: Error)
    }

    @State private var state: RequestState = .loading
    @Environment(\.dismiss) private var dismiss

    private func loadPreview() {
        let representation: CameraInitiatedTransferRepresentation =
            transferRequest.canProvide(.preview) ? .preview : .original
        transferRequest.executeTransfer(for: representation) { result, error in
            guard let result else {
                state = .failed(error: error ?? NSError(cblErrorCode: .noThumbnail))
                return
            }

            result.generatePreviewImage { image, error in
                guard let image else {
                    state = .failed(error: error ?? NSError(cblErrorCode: .noThumbnail))
                    return
                }

                state = .loaded(result: image)
            }
        }
    }

    var body: some View {
        VStack(spacing: 10.0) {
            Spacer(minLength: 0.0)
            switch state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case .loaded(let result):
                Image(nsImage: result)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failed(let error):
                Text("Failed")
                    .bold()
                Text(verbatim: error.localizedDescription)
            }
            Spacer(minLength: 0.0)
            HStack {
                Spacer(minLength: 0.0)
                Button("Close", action: { dismiss() })
            }
        }
        .padding()
        .frame(minWidth: 500.0, minHeight: 400.0)
        .task { loadPreview() }
    }
}
