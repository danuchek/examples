//
//  QRScannerInteractor.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

final class QRScannerInteractor {
    private weak var output: QRScannerInteractorOutput?
}

extension QRScannerInteractor: QRScannerInteractorInput {
    func attach(_ output: QRScannerInteractorOutput) {
        self.output = output
    }
}
