//
//  QRScannerError.swift
//
//  Created by Daniil Kabachuk on 22.01.2021.
//

import AVFoundation

enum QRScannerError: Error {
    case unauthorized(AVAuthorizationStatus)
    case deviceFailure(DeviceError)
    case readFailure
    case unknown

    enum DeviceError {
        case videoUnavailable
        case inputInvalid
        case metadataOutputFailure
        case videoDataOutputFailure
    }
}
