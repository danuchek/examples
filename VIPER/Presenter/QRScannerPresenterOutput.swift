//
//  QRScannerPresenterOutput.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

protocol QRScannerPresenterOutput: AnyObject {
    func setupUI()
    func rescan()
    func stopScanning()
}
