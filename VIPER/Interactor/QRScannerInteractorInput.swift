//
//  QRScannerInteractorInput.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

protocol QRScannerInteractorInput: AnyObject {
    func attach(_ output: QRScannerInteractorOutput)
}
