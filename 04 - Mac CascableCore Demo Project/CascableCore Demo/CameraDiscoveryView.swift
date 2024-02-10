import SwiftUI
import Combine
import CascableCore

struct CameraDiscoveryView: View {

    struct ConnectionState: Equatable {
        static func == (lhs: CameraDiscoveryView.ConnectionState, rhs: CameraDiscoveryView.ConnectionState) -> Bool {
            return lhs.buttonTitle == rhs.buttonTitle && lhs.buttonEnabled == rhs.buttonEnabled &&
                lhs.spinnerVisible == rhs.spinnerVisible
        }

        let buttonTitle: String
        let buttonEnabled: Bool
        let spinnerVisible: Bool
        let camera: Camera?

        static let idle = ConnectionState(buttonTitle: "Search for Camera…", buttonEnabled: true,
                                          spinnerVisible: false, camera: nil)
        static let searching = ConnectionState(buttonTitle: "Stop Searching", buttonEnabled: true,
                                               spinnerVisible: true, camera: nil)
        static func connecting(to camera: Camera) -> ConnectionState {
            return ConnectionState(buttonTitle: "Connecting…", buttonEnabled: false, spinnerVisible: true, camera: camera)
        }
    }

    @Binding var connectedCamera: Camera?
    @State private var state: ConnectionState = .idle
    @State private var isShowingConnectionError: Bool = false
    private let cameraDiscovery: BasicCameraDiscovery = .shared

    private func buttonClicked() {
        if state == .idle {
            cameraDiscovery.startDiscovery(clientName: "CascableCore Demo")
            state = .searching
        } else if state == .searching {
            cameraDiscovery.stopDiscovery()
            state = .idle
        }
    }

    var body: some View {
        VStack(spacing: 10.0) {
            Image(.coreIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180.0)
            Text("CascableCore Demo")
                .font(.title)
                .bold()
            Text("This project is a proof-of-concept to build a C# application that calls into a Swift framework. \n\n*This* project is a Mac demo app to build a Windows equivalent of.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400.0)

            HStack(spacing: 10.0) {
                if state.spinnerVisible {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
                Button(state.buttonTitle, action: buttonClicked)
                    .disabled(!state.buttonEnabled)
            }
        }
        .padding()
        .alert("Failed to Connect To Camera", isPresented: $isShowingConnectionError, actions: {
            Button("OK") {}
        }, message: {
            Text("This is particularly weird since we're using a simulated camera.")
        })
        .onReceive(Just(cameraDiscovery.visibleCameras), perform: { cameras in
            guard state == .searching, let camera = cameras.first else { return }
            cameraDiscovery.stopDiscovery()
            state = .connecting(to: camera)
            camera.connect(authenticationRequestCallback: { context in
                print("WARNING: Camera wants auth, and the basic API doesn't support that yet. Cancelling.")
                context.submitCancellation()
            }, authenticationResolvedCallback: {
                // Since we don't support camera auth in this demo, this is a no-op.
            }, completionCallback: { error, _ in
                if error != nil {
                    isShowingConnectionError = true
                    state = .idle
                } else if state == .connecting(to: camera) {
                    connectedCamera = camera
                    state = .idle
                }
            })
        })
    }
}
