//
//  QRScannerPresenterInput.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

protocol QRScannerPresenterInput: BasePresenting {
    func didSuccessScanning(_ code: String)
    func didFailureScanning()
    func closeScannerView()
}
