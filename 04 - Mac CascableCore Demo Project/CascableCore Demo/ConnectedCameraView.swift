import Foundation
import SwiftUI
import CascableCore

// We need this since we can't conform our `CameraInitiatedTransferRequest` protocol to `Identifiable` etc.
private struct IdentifiableCameraInitiatedTransferRequest: Identifiable {

    init(request: CameraInitiatedTransferRequest) {
        self.id = UUID()
        self.request = request
    }

    static func == (lhs: IdentifiableCameraInitiatedTransferRequest, rhs: IdentifiableCameraInitiatedTransferRequest) -> Bool {
        return lhs.request.isEqual(rhs.request)
    }

    let id: UUID
    let request: CameraInitiatedTransferRequest
}

struct ConnectedCameraView: View {

    let camera: Camera
    let cameraDisconnected: () -> Void

    private var cameraName: String {
        if let manufacturer = camera.deviceInfo?.manufacturer, let model = camera.deviceInfo?.model {
            return "\(manufacturer) \(model)"
        } else {
            return camera.friendlyDisplayName ?? "Camera"
        }
    }

    private func disconnectFromCamera() {
        if let token = cameraInitatedTransferToken {
            camera.removeCameraInitiatedTransferHandler(with: token)
            cameraInitatedTransferToken = nil
        }
        camera.disconnect({ _ in
            cameraDisconnected()
        }, callbackQueue: .main)
    }

    private func takePicture() {
        camera.invokeOneShotShutterExplicitlyEngagingAutoFocus(true)
    }

    private func startLiveView() {
        camera.beginStream(delivery: { frame, readyForNextFrame in
            if let image = frame.image { self.lastLiveViewImage = image }
            readyForNextFrame()
        }, deliveryQueue: .main, terminationHandler: { reason, error in
            print("Live view terminated: \(reason)")
        })
    }

    private func observeTransferRequests() {
        cameraInitatedTransferToken = camera.addCameraInitiatedTransferHandler({ request in
            guard request.isValid, request.canProvide(.preview) else { return }
            lastCameraInitiatedTransferRequest = .init(request: request)
        })
    }

    @State private var lastLiveViewImage: NSImage? = nil
    @State private var lastCameraInitiatedTransferRequest: IdentifiableCameraInitiatedTransferRequest? = nil
    @State private var cameraInitatedTransferToken: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            // Buttons
            HStack(spacing: 12.0) {
                Text(cameraName)
                    .bold()
                Button("Disconnect", action: disconnectFromCamera)
                Button("Take Picture", action: takePicture)
            }
            // Live View
            if let lastLiveViewImage {
                VStack {
                    Spacer(minLength: 0.0)
                    HStack {
                        Spacer(minLength: 0.0)
                        Image(nsImage: lastLiveViewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Spacer(minLength: 0.0)
                    }
                    Spacer(minLength: 0.0)
                }
            } else {
                Rectangle()
                    .foregroundStyle(.clear)
            }
            // Properties
            HStack(spacing: 0.0) {
                Spacer(minLength: 0.0)
                PropertyView(property: camera.property(with: .autoExposureMode))
                PropertyView(property: camera.property(with: .aperture))
                PropertyView(property: camera.property(with: .shutterSpeed))
                PropertyView(property: camera.property(with: .isoSpeed))
                PropertyView(property: camera.property(with: .exposureCompensation))
                Spacer(minLength: 0.0)
            }
        }
        .padding()
        .sheet(item: $lastCameraInitiatedTransferRequest) {
            PreviewSheet(transferRequest: $0.request)
        }
        .task {
            startLiveView()
            observeTransferRequests()
        }
    }
}
