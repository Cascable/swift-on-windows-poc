//
//  StopKitTests.swift
//  StopKitTests
//
//  Created by Daniel Kennett on 2022-07-07.
//  Copyright © 2022 Cascable AB. All rights reserved.
//

import XCTest
@testable import StopKit

class StopKitTests: XCTestCase {

    struct DurationAndExpectedOuput {
        let duration: TimeInterval
        let output: String
    }

    func testExtendedSonyShutterSpeeds() throws {

        let values: [DurationAndExpectedOuput] = [
            DurationAndExpectedOuput(duration: 1.0 / 32000.0, output: "1/32000"),
            DurationAndExpectedOuput(duration: 1.0 / 25600.0, output: "1/25600"),
            DurationAndExpectedOuput(duration: 1.0 / 24000.0, output: "1/24000"),
            DurationAndExpectedOuput(duration: 1.0 / 20000.0, output: "1/20000"),
            DurationAndExpectedOuput(duration: 1.0 / 16000.0, output: "1/16000"),
            DurationAndExpectedOuput(duration: 1.0 / 12800.0, output: "1/12800"),
            DurationAndExpectedOuput(duration: 1.0 / 12000.0, output: "1/12000"),
            DurationAndExpectedOuput(duration: 1.0 / 10000.0, output: "1/10000"),
        ]

        for testCase in values {
            let shutterSpeed = try XCTUnwrap(ShutterSpeedValue(approximateDuration: testCase.duration))
            XCTAssertEqual(shutterSpeed.fractionalRepresentation, testCase.output)
        }
    }

    func testSecureCodingRoundTrip() throws {

        let stops = ExposureStops(wholeStops: 1, fraction: .oneHalf, isNegative: false)
        let encodedStops = try NSKeyedArchiver.archivedData(withRootObject: stops, requiringSecureCoding: true)
        let decodedStops = try NSKeyedUnarchiver.unarchivedObject(ofClass: ExposureStops.self, from: encodedStops)
        XCTAssertEqual(stops, decodedStops)

        let shutterSpeed = ShutterSpeedValue.oneSecond
        let encodedSpeed = try NSKeyedArchiver.archivedData(withRootObject: shutterSpeed, requiringSecureCoding: true)
        let decodedSpeed = try NSKeyedUnarchiver.unarchivedObject(ofClass: ShutterSpeedValue.self, from: encodedSpeed)
        XCTAssertEqual(shutterSpeed, decodedSpeed)

        let shutterIndeterminateSpeed = IndeterminateShutterSpeedValue(name: "Hello")
        let encodedIndeterminateSpeed = try NSKeyedArchiver.archivedData(withRootObject: shutterIndeterminateSpeed, requiringSecureCoding: true)
        let decodedIndeterminateSpeed = try NSKeyedUnarchiver.unarchivedObject(ofClass: ShutterSpeedValue.self, from: encodedIndeterminateSpeed)
        XCTAssertEqual(shutterIndeterminateSpeed, decodedIndeterminateSpeed)

        let aperture = ApertureValue.f2Point8
        let encodedAperture = try NSKeyedArchiver.archivedData(withRootObject: aperture, requiringSecureCoding: true)
        let decodedAperture = try NSKeyedUnarchiver.unarchivedObject(ofClass: ApertureValue.self, from: encodedAperture)
        XCTAssertEqual(aperture, decodedAperture)

        let apertureIndeterminate = AutoApertureValue.automaticAperture
        let encodedIndeterminateAperture = try NSKeyedArchiver.archivedData(withRootObject: apertureIndeterminate, requiringSecureCoding: true)
        let decodedIndeterminateAperture = try NSKeyedUnarchiver.unarchivedObject(ofClass: ApertureValue.self, from: encodedIndeterminateAperture)
        XCTAssertEqual(apertureIndeterminate, decodedIndeterminateAperture)

        let isoSpeed = ISOValue.iso1600
        let encodedISO = try NSKeyedArchiver.archivedData(withRootObject: isoSpeed, requiringSecureCoding: true)
        let decodedISO = try NSKeyedUnarchiver.unarchivedObject(ofClass: ISOValue.self, from: encodedISO)
        XCTAssertEqual(isoSpeed, decodedISO)

        let isoIndeterminate = AutoISOValue.automaticISO
        let encodedIndeterminateISO = try NSKeyedArchiver.archivedData(withRootObject: isoIndeterminate, requiringSecureCoding: true)
        let decodedIndeterminateISO = try NSKeyedUnarchiver.unarchivedObject(ofClass: ISOValue.self, from: encodedIndeterminateISO)
        XCTAssertEqual(isoIndeterminate, decodedIndeterminateISO)

        let ev = ExposureCompensationValue.zeroEV
        let encodedEv = try NSKeyedArchiver.archivedData(withRootObject: ev, requiringSecureCoding: true)
        let decodedEv = try NSKeyedUnarchiver.unarchivedObject(ofClass: ExposureCompensationValue.self, from: encodedEv)
        XCTAssertEqual(ev, decodedEv)
    }
}
