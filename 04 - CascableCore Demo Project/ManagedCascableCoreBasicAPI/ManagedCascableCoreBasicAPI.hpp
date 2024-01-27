// This is an auto-generated file. Do not modify.

#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cliext/list> // This header requires "Conformance Mode" is disabled (/permissive)
#include <UnmanagedCascableCoreBasicAPI.hpp>

using namespace cliext;

namespace ManagedCascableCoreBasicAPI {

    ref class BasicPropertyIdentifier;
    ref class BasicCamera;
    ref class BasicCameraDiscovery;
    ref class BasicCameraProperty;
    ref class BasicDeviceInfo;
    ref class BasicPropertyValue;
    ref class BasicSimulatedCameraConfiguration;

    public ref class BasicPropertyIdentifier {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier *wrappedObj;
        BasicPropertyIdentifier(UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier *objectToTakeOwnershipOf);
    public:
        ~BasicPropertyIdentifier();
    
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ initWithRawValue(unsigned int rawValue);
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ isoSpeed();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ shutterSpeed();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ aperture();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ exposureCompensation();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ batteryLevel();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ powerSource();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ afSystem();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ focusMode();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ driveMode();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ autoExposureMode();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ inCameraBracketingEnabled();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ mirrorLockupEnabled();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ mirrorLockupStage();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ dofPreviewEnabled();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ shotsAvailable();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ lensStatus();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ colorTone();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ artFilter();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ digitalZoom();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ whiteBalance();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ noiseReduction();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ imageQuality();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ lightMeterStatus();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ lightMeterReading();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ exposureMeteringMode();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ readyForCapture();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ imageDestination();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ videoRecordingFormat();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ liveViewZoomLevel();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ maxValue();
        static ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ unknown();
        static bool operator==(ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ lhs, ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ rhs);
    
        bool isIsoSpeed();
        bool isShutterSpeed();
        bool isAperture();
        bool isExposureCompensation();
        bool isBatteryLevel();
        bool isPowerSource();
        bool isAfSystem();
        bool isFocusMode();
        bool isDriveMode();
        bool isAutoExposureMode();
        bool isInCameraBracketingEnabled();
        bool isMirrorLockupEnabled();
        bool isMirrorLockupStage();
        bool isDofPreviewEnabled();
        bool isShotsAvailable();
        bool isLensStatus();
        bool isColorTone();
        bool isArtFilter();
        bool isDigitalZoom();
        bool isWhiteBalance();
        bool isNoiseReduction();
        bool isImageQuality();
        bool isLightMeterStatus();
        bool isLightMeterReading();
        bool isExposureMeteringMode();
        bool isReadyForCapture();
        bool isImageDestination();
        bool isVideoRecordingFormat();
        bool isLiveViewZoomLevel();
        bool isMaxValue();
        bool isUnknown();
        unsigned int getRawValue();
    };

    public ref class BasicCamera {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicCamera *wrappedObj;
        BasicCamera(UnmanagedCascableCoreBasicAPI::BasicCamera *objectToTakeOwnershipOf);
    public:
        ~BasicCamera();
    
        System::String^ getFriendlyIdentifier();
        bool getConnected();
        ManagedCascableCoreBasicAPI::BasicDeviceInfo^ getDeviceInfo();
        System::String^ getFriendlyDisplayName();
        void connect();
        void disconnect();
        list <ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^>^ getKnownPropertyIdentifiers();
        ManagedCascableCoreBasicAPI::BasicCameraProperty^ property(ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ identifier);
    };

    public ref class BasicCameraDiscovery {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery *wrappedObj;
        BasicCameraDiscovery(UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery *objectToTakeOwnershipOf);
    public:
        ~BasicCameraDiscovery();
    
        static ManagedCascableCoreBasicAPI::BasicCameraDiscovery^ sharedInstance();
    
        bool getDiscoveryRunning();
        void setDiscoveryRunning(bool value);
        list <ManagedCascableCoreBasicAPI::BasicCamera^>^ getVisibleCameras();
        void startDiscovery(System::String^ clientName);
        void stopDiscovery();
    };

    public ref class BasicCameraProperty {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicCameraProperty *wrappedObj;
        BasicCameraProperty(UnmanagedCascableCoreBasicAPI::BasicCameraProperty *objectToTakeOwnershipOf);
    public:
        ~BasicCameraProperty();
    
        ManagedCascableCoreBasicAPI::BasicPropertyIdentifier^ getIdentifier();
        ManagedCascableCoreBasicAPI::BasicCamera^ getCamera();
        System::String^ getLocalizedDisplayName();
        ManagedCascableCoreBasicAPI::BasicPropertyValue^ getCurrentValue();
        void setCurrentValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ value);
        ManagedCascableCoreBasicAPI::BasicPropertyValue^ getPendingValue();
        void setPendingValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ value);
        list <ManagedCascableCoreBasicAPI::BasicPropertyValue^>^ getValidSettableValues();
        void setValidSettableValues(list<ManagedCascableCoreBasicAPI::BasicPropertyValue^>^ value);
        void setValue(ManagedCascableCoreBasicAPI::BasicPropertyValue^ newValue);
    };

    public ref class BasicDeviceInfo {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicDeviceInfo *wrappedObj;
        BasicDeviceInfo(UnmanagedCascableCoreBasicAPI::BasicDeviceInfo *objectToTakeOwnershipOf);
    public:
        ~BasicDeviceInfo();
    
        System::String^ getManufacturer();
        System::String^ getModel();
        System::String^ getVersion();
        System::String^ getSerialNumber();
    };

    public ref class BasicPropertyValue {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicPropertyValue *wrappedObj;
        BasicPropertyValue(UnmanagedCascableCoreBasicAPI::BasicPropertyValue *objectToTakeOwnershipOf);
    public:
        ~BasicPropertyValue();
    
        System::String^ getLocalizedDisplayValue();
        System::String^ getStringValue();
    };

    public ref class BasicSimulatedCameraConfiguration {
    private:
    internal:
        UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration *wrappedObj;
        BasicSimulatedCameraConfiguration(UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration *objectToTakeOwnershipOf);
    public:
        ~BasicSimulatedCameraConfiguration();
    
        static ManagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration^ defaultConfiguration();
    
        System::String^ getManufacturer();
        void setManufacturer(System::String^ value);
        System::String^ getModel();
        void setModel(System::String^ value);
        System::String^ getIdentifier();
        void setIdentifier(System::String^ value);
        void apply();
    };
}
