// This is an auto-generated file. Do not modify.

#ifndef UnmanagedCascableCoreBasicAPI_hpp
#define UnmanagedCascableCoreBasicAPI_hpp
#include <memory>
#include <string>
#include <optional>
#include <vector>

namespace CascableCoreBasicAPI {
    class BasicPropertyIdentifier;
    class BasicCamera;
    class BasicCameraDiscovery;
    class BasicCameraProperty;
    class BasicDeviceInfo;
    class BasicPropertyValue;
    class BasicSimulatedCameraConfiguration;
}

namespace UnmanagedCascableCoreBasicAPI {

    class BasicPropertyIdentifier;
    class BasicCamera;
    class BasicCameraDiscovery;
    class BasicCameraProperty;
    class BasicDeviceInfo;
    class BasicPropertyValue;
    class BasicSimulatedCameraConfiguration;

    class BasicPropertyIdentifier {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicPropertyIdentifier> swiftObj;
        BasicPropertyIdentifier(std::shared_ptr<CascableCoreBasicAPI::BasicPropertyIdentifier> swiftObj);
        ~BasicPropertyIdentifier();
    
        static std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier> initWithRawValue(unsigned int rawValue);
    
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier isoSpeed();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier shutterSpeed();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier aperture();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier exposureCompensation();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier batteryLevel();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier powerSource();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier afSystem();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier focusMode();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier driveMode();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier autoExposureMode();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier inCameraBracketingEnabled();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier mirrorLockupEnabled();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier mirrorLockupStage();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier dofPreviewEnabled();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier shotsAvailable();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier lensStatus();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier colorTone();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier artFilter();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier digitalZoom();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier whiteBalance();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier noiseReduction();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier imageQuality();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier lightMeterStatus();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier lightMeterReading();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier exposureMeteringMode();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier readyForCapture();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier imageDestination();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier videoRecordingFormat();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier liveViewZoomLevel();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier maxValue();
        static UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier unknown();
    
        bool operator==(const UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier &other) const;
    
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

    class BasicCamera {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicCamera> swiftObj;
        BasicCamera(std::shared_ptr<CascableCoreBasicAPI::BasicCamera> swiftObj);
        ~BasicCamera();
    
        std::optional<std::string> getFriendlyIdentifier();
        bool getConnected();
        std::optional<UnmanagedCascableCoreBasicAPI::BasicDeviceInfo> getDeviceInfo();
        std::optional<std::string> getFriendlyDisplayName();
        void connect();
        void disconnect();
        std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier> getKnownPropertyIdentifiers();
        UnmanagedCascableCoreBasicAPI::BasicCameraProperty property(const UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier & identifier);
    };

    class BasicCameraDiscovery {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicCameraDiscovery> swiftObj;
        BasicCameraDiscovery(std::shared_ptr<CascableCoreBasicAPI::BasicCameraDiscovery> swiftObj);
        ~BasicCameraDiscovery();
    
        static UnmanagedCascableCoreBasicAPI::BasicCameraDiscovery sharedInstance();
        bool getDiscoveryRunning();
        void setDiscoveryRunning(bool value);
        std::vector<UnmanagedCascableCoreBasicAPI::BasicCamera> getVisibleCameras();
        void startDiscovery(const std::string & clientName);
        void stopDiscovery();
    };

    class BasicCameraProperty {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicCameraProperty> swiftObj;
        BasicCameraProperty(std::shared_ptr<CascableCoreBasicAPI::BasicCameraProperty> swiftObj);
        ~BasicCameraProperty();
    
        UnmanagedCascableCoreBasicAPI::BasicPropertyIdentifier getIdentifier();
        std::optional<UnmanagedCascableCoreBasicAPI::BasicCamera> getCamera();
        std::optional<std::string> getLocalizedDisplayName();
        std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> getCurrentValue();
        void setCurrentValue(const std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> & value);
        std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> getPendingValue();
        void setPendingValue(const std::optional<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> & value);
        std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> getValidSettableValues();
        void setValidSettableValues(std::vector<UnmanagedCascableCoreBasicAPI::BasicPropertyValue> value);
        void setValue(const UnmanagedCascableCoreBasicAPI::BasicPropertyValue & newValue);
    };

    class BasicDeviceInfo {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicDeviceInfo> swiftObj;
        BasicDeviceInfo(std::shared_ptr<CascableCoreBasicAPI::BasicDeviceInfo> swiftObj);
        ~BasicDeviceInfo();
    
        std::optional<std::string> getManufacturer();
        std::optional<std::string> getModel();
        std::optional<std::string> getVersion();
        std::optional<std::string> getSerialNumber();
    };

    class BasicPropertyValue {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicPropertyValue> swiftObj;
        BasicPropertyValue(std::shared_ptr<CascableCoreBasicAPI::BasicPropertyValue> swiftObj);
        ~BasicPropertyValue();
    
        std::optional<std::string> getLocalizedDisplayValue();
        std::string getStringValue();
    };

    class BasicSimulatedCameraConfiguration {
    private:
    public:
        std::shared_ptr<CascableCoreBasicAPI::BasicSimulatedCameraConfiguration> swiftObj;
        BasicSimulatedCameraConfiguration(std::shared_ptr<CascableCoreBasicAPI::BasicSimulatedCameraConfiguration> swiftObj);
        ~BasicSimulatedCameraConfiguration();
    
        static UnmanagedCascableCoreBasicAPI::BasicSimulatedCameraConfiguration defaultConfiguration();
        std::string getManufacturer();
        void setManufacturer(const std::string & value);
        std::string getModel();
        void setModel(const std::string & value);
        std::string getIdentifier();
        void setIdentifier(const std::string & value);
        void apply();
    };
}

#endif /* UnmanagedCascableCoreBasicAPI_hpp */
