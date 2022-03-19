//
//  QRScannerAssembler.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

final class QRScannerAssembler {
    static func createModule(completion: @escaping TextHandler) -> QRScannerViewController {
        let viewController = QRScannerViewController()
        let router = QRScannerRouter(viewController)
        let interactor = QRScannerInteractor()
        let presenter = QRScannerPresenter(router, interactor, viewController, completion)
        viewController.presenter = presenter
        return viewController
    }
}
