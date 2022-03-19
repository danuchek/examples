//
//  QRScannerRouting.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

protocol QRScannerRouting: BaseRouting {
    func shouldRescan(completion: @escaping BoolHandler)
    func showRedirectAlert(with message: String)
}
