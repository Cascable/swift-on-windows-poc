import SwiftUI
import CascableCore

@main
struct CascableCoreDemo: App {
    
    @State private var connectedCamera: Camera? = nil

    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle()
                    .foregroundStyle(.background)
                if let connectedCamera {
                    ConnectedCameraView(camera: connectedCamera, cameraDisconnected: {
                        self.connectedCamera = nil
                    })
                } else {
                    CameraDiscoveryView(connectedCamera: $connectedCamera)
                }
            }
            .frame(minWidth: 700.0, minHeight: 580.0)
        }
        .windowResizability(.contentMinSize)
    }
}
