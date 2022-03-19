//
//  QRScannerViewDelegate.swift
//
//  Created by Daniil Kabachuk on 22.01.2021.
//

protocol QRScannerViewDelegate: AnyObject {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError)
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String)
    func setTorchImage(with state: QRScannerViewController.TorchButtonState)
}
