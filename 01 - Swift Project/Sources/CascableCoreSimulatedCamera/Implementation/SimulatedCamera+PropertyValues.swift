//
//  SimulatedCamera+PropertyValues.swift
//  CascableCore Simulated Camera Plugin
//
//  Created by Daniel Kennett (Cascable) on 2023-12-05.
//  Copyright © 2023 Cascable AB. All rights reserved.
//

import Foundation
import StopKit
import CascableCoreAPI

struct PropertyValuesWithSuggestedDefault {
    let defaultValue: SimulatedPropertyValue?
    let validValues: [SimulatedPropertyValue]?
}

extension SimulatedCamera {

    func createFocusModeValues() -> PropertyValuesWithSuggestedDefault {
        let bundle = Bundle.forLocalizations
        let singleAf = SimulatedPropertyValue(commonValue: PropertyCommonValueFocusMode.singleDrive.rawValue,
                                              localizedDisplayValue: bundle.localizedString(forKey: "AF-S", value: nil, table: "SonyFocusModes"))

        return PropertyValuesWithSuggestedDefault(defaultValue: singleAf, validValues: [
            singleAf,
            SimulatedPropertyValue(commonValue: PropertyCommonValueFocusMode.continuousDrive.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "AF-C", value: nil, table: "SonyFocusModes")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueFocusMode.manual.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "MF", value: nil, table: "SonyFocusModes"))
        ])
    }

    func createAFSystemValues() -> PropertyValuesWithSuggestedDefault {
        let bundle = Bundle.forLocalizations
        let singleArea = SimulatedPropertyValue(commonValue: PropertyCommonValueAFSystem.singleArea.rawValue,
                                                localizedDisplayValue: bundle.localizedString(forKey: "EOSLiveViewAFSystemSinglePointFlexiZone", value: nil, table: "CanonLVAFSystems"))

        return PropertyValuesWithSuggestedDefault(defaultValue: singleArea, validValues: [
                singleArea,
                SimulatedPropertyValue(commonValue: PropertyCommonValueAFSystem.multipleAreas.rawValue,
                                       localizedDisplayValue: bundle.localizedString(forKey: "EOSLiveViewAFSystemFlexiZoneMulti", value: nil, table: "CanonLVAFSystems")),
                SimulatedPropertyValue(commonValue: PropertyCommonValueAFSystem.faceDetection.rawValue,
                                       localizedDisplayValue: bundle.localizedString(forKey: "EOSLiveViewAFSystemFaceDetect", value: nil, table: "CanonLVAFSystems"))
        ])
    }

    func createDriveModeValues() -> PropertyValuesWithSuggestedDefault {
        let bundle = Bundle.forLocalizations
        let singleShot = SimulatedPropertyValue(commonValue: PropertyCommonValueDriveMode.singleShot.rawValue,
                                                localizedDisplayValue: bundle.localizedString(forKey: "EOSDriveModeSingle", value: nil, table: "CanonDriveModes"))

        return PropertyValuesWithSuggestedDefault(defaultValue: singleShot, validValues: [
            singleShot,
            SimulatedPropertyValue(commonValue: PropertyCommonValueDriveMode.continuous.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSDriveModeContinuous", value: nil, table: "CanonDriveModes")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueDriveMode.timerLong.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSDriveMode10SecTimer", value: nil, table: "CanonDriveModes"))
        ])
    }

    func createWhiteBalanceValues() -> PropertyValuesWithSuggestedDefault {
        let bundle = Bundle.forLocalizations
        let sunny = SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.daylight.rawValue,
                                           localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceDaylight", value: nil, table: "CanonWhiteBalances"))

        return PropertyValuesWithSuggestedDefault(defaultValue: sunny, validValues: [
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.auto.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceAuto", value: nil, table: "CanonWhiteBalances")),
            sunny,
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.shade.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceShade", value: nil, table: "CanonWhiteBalances")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.cloudy.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceCloudy", value: nil, table: "CanonWhiteBalances")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.tungsten.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceIncandescent", value: nil, table: "CanonWhiteBalances")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.fluorescent.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceWhiteFluorescent", value: nil, table: "CanonWhiteBalances")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.flash.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceFlash", value: nil, table: "CanonWhiteBalances")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueWhiteBalance.custom.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSWhiteBalanceColorTemp", value: nil, table: "CanonWhiteBalances")),
        ])
    }

    func createAEModeValues() -> PropertyValuesWithSuggestedDefault {
        let bundle = Bundle.forLocalizations
        let programAuto = SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.programAuto.rawValue,
                                                 localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeProgram", value: nil, table: "CanonAEModes"))

        return PropertyValuesWithSuggestedDefault(defaultValue: programAuto, validValues: [
            SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.bulb.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeBulb", value: nil, table: "CanonAEModes")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.fullyAutomatic.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeSceneIntelligentAuto", value: nil, table: "CanonAEModes")),
            programAuto,
            SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.aperturePriority.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeAv", value: nil, table: "CanonAEModes")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.shutterPriority.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeTv", value: nil, table: "CanonAEModes")),
            SimulatedPropertyValue(commonValue: PropertyCommonValueAutoExposureMode.fullyManual.rawValue,
                                   localizedDisplayValue: bundle.localizedString(forKey: "EOSAEModeManual", value: nil, table: "CanonAEModes")),
        ])
    }

    func createExposureCompensationValues(for aeMode: PropertyCommonValueAutoExposureMode) -> PropertyValuesWithSuggestedDefault {
        switch aeMode {
        case .fullyManual, .bulb:
            return PropertyValuesWithSuggestedDefault(defaultValue: nil, validValues: [])

        case .fullyAutomatic, .programAuto, .flexiblePriority, .shutterPriority, .aperturePriority:
            let EVs: [ExposureCompensationValue] = [
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 3, fraction: .none, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .twoThirds, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .oneThird, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .none, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .twoThirds, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .oneThird, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .none, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 0, fraction: .twoThirds, isNegative: true)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 0, fraction: .oneThird, isNegative: true)),
                ExposureCompensationValue.zeroEV,
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 0, fraction: .oneThird, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 0, fraction: .twoThirds, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .none, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .oneThird, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 1, fraction: .twoThirds, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .none, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .oneThird, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 2, fraction: .twoThirds, isNegative: false)),
                ExposureCompensationValue(stopsFromZeroEV: ExposureStops(wholeStops: 3, fraction: .none, isNegative: false))
            ]

            return PropertyValuesWithSuggestedDefault(defaultValue: SimulatedExposurePropertyValue(ExposureCompensationValue.zeroEV),
                                                      validValues: EVs.map({ SimulatedExposurePropertyValue($0) }))
        }
    }

    func createApertureValues(for aeMode: PropertyCommonValueAutoExposureMode) throws -> PropertyValuesWithSuggestedDefault {
        switch aeMode {
        case .fullyManual, .bulb, .aperturePriority:
            var apertures = [ApertureValue]()
            apertures.append(ApertureValue.f2Point8)
            let f16: ApertureValue = ApertureValue.f16
            var lastAperture: ApertureValue = ApertureValue.f2Point8

            while try lastAperture.compare(to: f16) == ComparisonResult.orderedDescending {
                lastAperture = try lastAperture.valueByAdding(ExposureStops(wholeStops: 0, fraction: .oneThird, isNegative: true))
                apertures.append(lastAperture)
            }

            return PropertyValuesWithSuggestedDefault(defaultValue: SimulatedExposurePropertyValue(ApertureValue.f4),
                                                      validValues: apertures.map({ SimulatedExposurePropertyValue($0) }))

        case .fullyAutomatic, .programAuto, .flexiblePriority, .shutterPriority:
            return PropertyValuesWithSuggestedDefault(defaultValue: nil, validValues: [])
        }
    }

    func createShutterSpeedValues(for aeMode: PropertyCommonValueAutoExposureMode) throws -> PropertyValuesWithSuggestedDefault {
        switch aeMode {
        case .fullyManual, .bulb, .shutterPriority:
            let thirtySec = ShutterSpeedValue(approximateDuration: 30.0)!
            let one8000 = ShutterSpeedValue(approximateDuration: 1.0 / 8000.0)!
            var shutterSpeeds = Array(try ShutterSpeedValue.shutterSpeeds(between: one8000, and: thirtySec).reversed())
            shutterSpeeds.insert(ShutterSpeedValue.bulb, at: 0)

            return PropertyValuesWithSuggestedDefault(defaultValue: SimulatedExposurePropertyValue(ShutterSpeedValue.oneTwoHundredFiftieth),
                                                      validValues: shutterSpeeds.map({ SimulatedExposurePropertyValue($0) }))

        case .fullyAutomatic, .programAuto, .flexiblePriority, .aperturePriority:
            return PropertyValuesWithSuggestedDefault(defaultValue: nil, validValues: [])
        }
    }

    // MARK: - Property Identifiers

    private func localizedUniversalProperty(key: String) -> String {
        let bundle = Bundle.forLocalizations
        return bundle.localizedString(forKey: key, value: nil, table: "UniversalProperties")
    }

    internal func localizedDisplayName(forProperty property: PropertyIdentifier) -> String {
        switch property {
        case .afSystem:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierAFSystem")
        case .aperture:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierAperture")
        case .artFilter:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierArtFilter")
        case .autoExposureMode:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierAutoExposureMode")
        case .batteryLevel:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierBatteryLevel")
        case .colorTone:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierColorTone")
        case .digitalZoom:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierDigitalZoom")
        case .dofPreviewEnabled:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierDOFPreviewEnabled")
        case .driveMode:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierDriveMode")
        case .exposureCompensation:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierExposureCompensation")
        case .focusMode:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierFocusMode")
        case .imageQuality:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierImageQuality")
        case .inCameraBracketingEnabled:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierInCameraBracketingEnabled")
        case .isoSpeed:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierISOSpeed")
        case .lensStatus:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierLensStatus")
        case .mirrorLockupEnabled:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierMirrorLockupEnabled")
        case .mirrorLockupStage:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierMirrorLockupStage")
        case .noiseReduction:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierNoiseReduction")
        case .powerSource:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierPowerSource")
        case .shotsAvailable:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierShotsAvailable")
        case .shutterSpeed:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierShutterSpeed")
        case .whiteBalance:
            return localizedUniversalProperty(key: "CBLPropertyIdentifierWhiteBalance")
        default:
            return "Unknown"
        }
    }


}
