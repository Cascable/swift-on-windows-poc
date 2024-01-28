// This is an auto-generated file. Do not modify.

#include "ManagedCascableCoreBasicAPI.hpp"
#include <msclr/marshal_cppstd.h>

using namespace msclr::interop;
using namespace System::Collections::Generic;

// Implementation of ManagedCascableCoreBasicAPI::BasicPropertyIdentifier

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::BasicPropertyIdentifier(UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::~BasicPropertyIdentifier() {
    delete wrappedObj;
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::initWithRawValue(unsigned int rawValue) {
    unsigned int arg0 = rawValue;
    std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier> unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::initWithRawValue(arg0);
    return (unmanagedResult.has_value() ? gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult.value())) : nullptr);
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isoSpeed() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::isoSpeed();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::shutterSpeed() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::shutterSpeed();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::aperture() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::aperture();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::exposureCompensation() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::exposureCompensation();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::batteryLevel() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::batteryLevel();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::powerSource() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::powerSource();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::afSystem() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::afSystem();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::focusMode() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::focusMode();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::driveMode() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::driveMode();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::autoExposureMode() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::autoExposureMode();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::inCameraBracketingEnabled() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::inCameraBracketingEnabled();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::mirrorLockupEnabled() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::mirrorLockupEnabled();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::mirrorLockupStage() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::mirrorLockupStage();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::dofPreviewEnabled() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::dofPreviewEnabled();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::shotsAvailable() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::shotsAvailable();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::lensStatus() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::lensStatus();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::colorTone() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::colorTone();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::artFilter() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::artFilter();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::digitalZoom() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::digitalZoom();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::whiteBalance() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::whiteBalance();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::noiseReduction() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::noiseReduction();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::imageQuality() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::imageQuality();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::lightMeterStatus() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::lightMeterStatus();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::lightMeterReading() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::lightMeterReading();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::exposureMeteringMode() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::exposureMeteringMode();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::readyForCapture() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::readyForCapture();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::imageDestination() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::imageDestination();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::videoRecordingFormat() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::videoRecordingFormat();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::liveViewZoomLevel() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::liveViewZoomLevel();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::maxValue() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::maxValue();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::unknown() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier::unknown();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::operator==(ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ lhs, ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ rhs) {
    if (Object::ReferenceEquals(lhs, nullptr) && Object::ReferenceEquals(rhs, nullptr)) { return true; }
    if (Object::ReferenceEquals(lhs, nullptr) || Object::ReferenceEquals(rhs, nullptr)) { return false; }
    return (*lhs->wrappedObj == *rhs->wrappedObj);
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isIsoSpeed() {
    bool unmanagedResult = wrappedObj->isIsoSpeed();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isShutterSpeed() {
    bool unmanagedResult = wrappedObj->isShutterSpeed();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isAperture() {
    bool unmanagedResult = wrappedObj->isAperture();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isExposureCompensation() {
    bool unmanagedResult = wrappedObj->isExposureCompensation();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isBatteryLevel() {
    bool unmanagedResult = wrappedObj->isBatteryLevel();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isPowerSource() {
    bool unmanagedResult = wrappedObj->isPowerSource();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isAfSystem() {
    bool unmanagedResult = wrappedObj->isAfSystem();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isFocusMode() {
    bool unmanagedResult = wrappedObj->isFocusMode();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isDriveMode() {
    bool unmanagedResult = wrappedObj->isDriveMode();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isAutoExposureMode() {
    bool unmanagedResult = wrappedObj->isAutoExposureMode();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isInCameraBracketingEnabled() {
    bool unmanagedResult = wrappedObj->isInCameraBracketingEnabled();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isMirrorLockupEnabled() {
    bool unmanagedResult = wrappedObj->isMirrorLockupEnabled();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isMirrorLockupStage() {
    bool unmanagedResult = wrappedObj->isMirrorLockupStage();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isDofPreviewEnabled() {
    bool unmanagedResult = wrappedObj->isDofPreviewEnabled();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isShotsAvailable() {
    bool unmanagedResult = wrappedObj->isShotsAvailable();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isLensStatus() {
    bool unmanagedResult = wrappedObj->isLensStatus();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isColorTone() {
    bool unmanagedResult = wrappedObj->isColorTone();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isArtFilter() {
    bool unmanagedResult = wrappedObj->isArtFilter();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isDigitalZoom() {
    bool unmanagedResult = wrappedObj->isDigitalZoom();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isWhiteBalance() {
    bool unmanagedResult = wrappedObj->isWhiteBalance();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isNoiseReduction() {
    bool unmanagedResult = wrappedObj->isNoiseReduction();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isImageQuality() {
    bool unmanagedResult = wrappedObj->isImageQuality();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isLightMeterStatus() {
    bool unmanagedResult = wrappedObj->isLightMeterStatus();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isLightMeterReading() {
    bool unmanagedResult = wrappedObj->isLightMeterReading();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isExposureMeteringMode() {
    bool unmanagedResult = wrappedObj->isExposureMeteringMode();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isReadyForCapture() {
    bool unmanagedResult = wrappedObj->isReadyForCapture();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isImageDestination() {
    bool unmanagedResult = wrappedObj->isImageDestination();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isVideoRecordingFormat() {
    bool unmanagedResult = wrappedObj->isVideoRecordingFormat();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isLiveViewZoomLevel() {
    bool unmanagedResult = wrappedObj->isLiveViewZoomLevel();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isMaxValue() {
    bool unmanagedResult = wrappedObj->isMaxValue();
    return unmanagedResult;
}

bool ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::isUnknown() {
    bool unmanagedResult = wrappedObj->isUnknown();
    return unmanagedResult;
}

unsigned int ManagedCascableCoreBasicAPI::BasicPropertyIdentifier::getRawValue() {
    unsigned int unmanagedResult = wrappedObj->getRawValue();
    return unmanagedResult;
}

// Implementation of ManagedCascableCoreBasicAPI::BasicCamera

ManagedCascableCoreBasicAPI::BasicCamera::BasicCamera(UnmanagedCascableCoreBasicAPI::BasicCamera* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicCamera::~BasicCamera() {
    delete wrappedObj;
}

System::String^ ManagedCascableCoreBasicAPI::BasicCamera::getFriendlyIdentifier() {
    std::optional<std::string> unmanagedResult = wrappedObj->getFriendlyIdentifier();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

bool ManagedCascableCoreBasicAPI::BasicCamera::getConnected() {
    bool unmanagedResult = wrappedObj->getConnected();
    return unmanagedResult;
}

ManagedCascableCoreBasicAPI::BasicDeviceInfo^ ManagedCascableCoreBasicAPI::BasicCamera::getDeviceInfo() {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicDeviceInfo> unmanagedResult = wrappedObj->getDeviceInfo();
    return (unmanagedResult.has_value() ? gcnew ManagedCascableCoreBasicAPI::BasicDeviceInfo(new UnmanagedCascableCoreBasicAPI::BasicDeviceInfo(unmanagedResult.value())) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicCamera::getFriendlyDisplayName() {
    std::optional<std::string> unmanagedResult = wrappedObj->getFriendlyDisplayName();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

void ManagedCascableCoreBasicAPI::BasicCamera::connect() {
    wrappedObj->connect();
}

void ManagedCascableCoreBasicAPI::BasicCamera::disconnect() {
    wrappedObj->disconnect();
}

List<ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^>^ ManagedCascableCoreBasicAPI::BasicCamera::getKnownPropertyIdentifiers() {
    std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier> unmanagedResult = wrappedObj->getKnownPropertyIdentifiers();
    List<ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^>^ managedResult = gcnew List<ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^>();
    for (auto element : unmanagedResult) {
        auto managedElement = gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(element));
        managedResult->Add(managedElement);
    }
    return managedResult;
}

ManagedCascableCoreBasicAPI::BasicCameraProperty^ ManagedCascableCoreBasicAPI::BasicCamera::property(ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ identifier) {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier arg0 = *identifier->wrappedObj;
    UnmanagedCascableCoreBasicAPI::BasicCameraProperty unmanagedResult = wrappedObj->property(arg0);
    return gcnew ManagedCascableCoreBasicAPI::BasicCameraProperty(new UnmanagedCascableCoreBasicAPI::BasicCameraProperty(unmanagedResult));
}

// Implementation of ManagedCascableCoreBasicAPI::BasicCameraDiscovery

ManagedCascableCoreBasicAPI::BasicCameraDiscovery::BasicCameraDiscovery(UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicCameraDiscovery::~BasicCameraDiscovery() {
    delete wrappedObj;
}

ManagedCascableCoreBasicAPI::BasicCameraDiscovery^ ManagedCascableCoreBasicAPI::BasicCameraDiscovery::sharedInstance() {
    UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery::sharedInstance();
    return gcnew ManagedCascableCoreBasicAPI::BasicCameraDiscovery(new UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery(unmanagedResult));
}

bool ManagedCascableCoreBasicAPI::BasicCameraDiscovery::getDiscoveryRunning() {
    bool unmanagedResult = wrappedObj->getDiscoveryRunning();
    return unmanagedResult;
}

void ManagedCascableCoreBasicAPI::BasicCameraDiscovery::setDiscoveryRunning(bool value) {
    bool arg0 = value;
    wrappedObj->setDiscoveryRunning(arg0);
}

List<ManagedCascableCoreBasicAPI::BasicCamera^>^ ManagedCascableCoreBasicAPI::BasicCameraDiscovery::getVisibleCameras() {
    std::vector<UnmanagedCascableCoreBasicAPI::BasicCamera> unmanagedResult = wrappedObj->getVisibleCameras();
    List<ManagedCascableCoreBasicAPI::BasicCamera^>^ managedResult = gcnew List<ManagedCascableCoreBasicAPI::BasicCamera^>();
    for (auto element : unmanagedResult) {
        auto managedElement = gcnew ManagedCascableCoreBasicAPI::BasicCamera(new UnmanagedCascableCoreBasicAPI::BasicCamera(element));
        managedResult->Add(managedElement);
    }
    return managedResult;
}

void ManagedCascableCoreBasicAPI::BasicCameraDiscovery::startDiscovery(System::String^ clientName) {
    const std::string& arg0 = marshal_as<std::string>(clientName);
    wrappedObj->startDiscovery(arg0);
}

void ManagedCascableCoreBasicAPI::BasicCameraDiscovery::stopDiscovery() {
    wrappedObj->stopDiscovery();
}

// Implementation of ManagedCascableCoreBasicAPI::BasicCameraProperty

ManagedCascableCoreBasicAPI::BasicCameraProperty::BasicCameraProperty(UnmanagedCascableCoreBasicAPI::BasicCameraProperty* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicCameraProperty::~BasicCameraProperty() {
    delete wrappedObj;
}

ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getIdentifier() {
    UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unmanagedResult = wrappedObj->getIdentifier();
    return gcnew ManagedCascableCoreBasicAPI::BasicPropertyIdentifier(new UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier(unmanagedResult));
}

ManagedCascableCoreBasicAPI::BasicCamera^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getCamera() {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicCamera> unmanagedResult = wrappedObj->getCamera();
    return (unmanagedResult.has_value() ? gcnew ManagedCascableCoreBasicAPI::BasicCamera(new UnmanagedCascableCoreBasicAPI::BasicCamera(unmanagedResult.value())) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getLocalizedDisplayName() {
    std::optional<std::string> unmanagedResult = wrappedObj->getLocalizedDisplayName();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

ManagedCascableCoreBasicAPI::BasicPropertyValue^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getCurrentValue() {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> unmanagedResult = wrappedObj->getCurrentValue();
    return (unmanagedResult.has_value() ? gcnew ManagedCascableCoreBasicAPI::BasicPropertyValue(new UnmanagedCascableCoreBasicAPI::BasicPropertyValue(unmanagedResult.value())) : nullptr);
}

void ManagedCascableCoreBasicAPI::BasicCameraProperty::setCurrentValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ value) {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> arg0 = (value == nullptr ? std::nullopt : std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue>(*value->wrappedObj));
    wrappedObj->setCurrentValue(arg0);
}

ManagedCascableCoreBasicAPI::BasicPropertyValue^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getPendingValue() {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> unmanagedResult = wrappedObj->getPendingValue();
    return (unmanagedResult.has_value() ? gcnew ManagedCascableCoreBasicAPI::BasicPropertyValue(new UnmanagedCascableCoreBasicAPI::BasicPropertyValue(unmanagedResult.value())) : nullptr);
}

void ManagedCascableCoreBasicAPI::BasicCameraProperty::setPendingValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ value) {
    std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> arg0 = (value == nullptr ? std::nullopt : std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue>(*value->wrappedObj));
    wrappedObj->setPendingValue(arg0);
}

List<ManagedCascableCoreBasicAPI::BasicPropertyValue^>^ ManagedCascableCoreBasicAPI::BasicCameraProperty::getValidSettableValues() {
    std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> unmanagedResult = wrappedObj->getValidSettableValues();
    List<ManagedCascableCoreBasicAPI::BasicPropertyValue^>^ managedResult = gcnew List<ManagedCascableCoreBasicAPI::BasicPropertyValue^>();
    for (auto element : unmanagedResult) {
        auto managedElement = gcnew ManagedCascableCoreBasicAPI::BasicPropertyValue(new UnmanagedCascableCoreBasicAPI::BasicPropertyValue(element));
        managedResult->Add(managedElement);
    }
    return managedResult;
}

void ManagedCascableCoreBasicAPI::BasicCameraProperty::setValidSettableValues(List<ManagedCascableCoreBasicAPI::BasicPropertyValue^>^ value) {
    std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> arg0Array;
    arg0Array.reserve(value->Count);
    for each (auto element in value) {
        arg0Array.push_back(*element->wrappedObj);
    }
    wrappedObj->setValidSettableValues(arg0Array);
}

void ManagedCascableCoreBasicAPI::BasicCameraProperty::setValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ newValue) {
    UnmanagedCascableCoreBasicAPI::BasicPropertyValue arg0 = *newValue->wrappedObj;
    wrappedObj->setValue(arg0);
}

// Implementation of ManagedCascableCoreBasicAPI::BasicDeviceInfo

ManagedCascableCoreBasicAPI::BasicDeviceInfo::BasicDeviceInfo(UnmanagedCascableCoreBasicAPI::BasicDeviceInfo* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicDeviceInfo::~BasicDeviceInfo() {
    delete wrappedObj;
}

System::String^ ManagedCascableCoreBasicAPI::BasicDeviceInfo::getManufacturer() {
    std::optional<std::string> unmanagedResult = wrappedObj->getManufacturer();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicDeviceInfo::getModel() {
    std::optional<std::string> unmanagedResult = wrappedObj->getModel();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicDeviceInfo::getVersion() {
    std::optional<std::string> unmanagedResult = wrappedObj->getVersion();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicDeviceInfo::getSerialNumber() {
    std::optional<std::string> unmanagedResult = wrappedObj->getSerialNumber();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

// Implementation of ManagedCascableCoreBasicAPI::BasicPropertyValue

ManagedCascableCoreBasicAPI::BasicPropertyValue::BasicPropertyValue(UnmanagedCascableCoreBasicAPI::BasicPropertyValue* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicPropertyValue::~BasicPropertyValue() {
    delete wrappedObj;
}

System::String^ ManagedCascableCoreBasicAPI::BasicPropertyValue::getLocalizedDisplayValue() {
    std::optional<std::string> unmanagedResult = wrappedObj->getLocalizedDisplayValue();
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

System::String^ ManagedCascableCoreBasicAPI::BasicPropertyValue::getStringValue() {
    std::string unmanagedResult = wrappedObj->getStringValue();
    return marshal_as<System::String^>(unmanagedResult);
}

// Implementation of ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration

ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::BasicSimulatedCameraConfiguration(UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::~BasicSimulatedCameraConfiguration() {
    delete wrappedObj;
}

ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration^ ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::defaultConfiguration() {
    UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration unmanagedResult = UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::defaultConfiguration();
    return gcnew ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration(new UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration(unmanagedResult));
}

System::String^ ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::getManufacturer() {
    std::string unmanagedResult = wrappedObj->getManufacturer();
    return marshal_as<System::String^>(unmanagedResult);
}

void ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::setManufacturer(System::String^ value) {
    const std::string& arg0 = marshal_as<std::string>(value);
    wrappedObj->setManufacturer(arg0);
}

System::String^ ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::getModel() {
    std::string unmanagedResult = wrappedObj->getModel();
    return marshal_as<System::String^>(unmanagedResult);
}

void ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::setModel(System::String^ value) {
    const std::string& arg0 = marshal_as<std::string>(value);
    wrappedObj->setModel(arg0);
}

System::String^ ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::getIdentifier() {
    std::string unmanagedResult = wrappedObj->getIdentifier();
    return marshal_as<System::String^>(unmanagedResult);
}

void ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::setIdentifier(System::String^ value) {
    const std::string& arg0 = marshal_as<std::string>(value);
    wrappedObj->setIdentifier(arg0);
}

void ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration::apply() {
    wrappedObj->apply();
}
