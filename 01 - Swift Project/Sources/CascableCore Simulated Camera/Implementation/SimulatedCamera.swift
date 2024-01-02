protocol SimulatedCameraDelegate: AnyObject {
    func simulatedCameraDidDisconnect(_ camera: SimulatedCamera)
}

class SimulatedCamera: Camera {

    init(configuration: SimulatedCameraConfiguration, clientName: String, transport: CameraTransport) {

    }

    weak var simulatedCameraDelegate: SimulatedCameraDelegate? = nil

}