//
//  QRScannerRouter.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

import UIKit

final class QRScannerRouter: BaseRouter {}

extension QRScannerRouter: QRScannerRouting {
    func shouldRescan(completion: @escaping BoolHandler) {
        let yesAction = UIAlertAction(title: L10n.BaseRouting.alertYes, style: .default) { _ in
            completion(true)
        }
        let noAction = UIAlertAction(title: L10n.BaseRouting.alertNo, style: .default) { [weak self] _ in
            self?.dismiss()
        }
        showAlert(title: L10n.QRScanner.failureAlertTitle,
                  message: L10n.QRScanner.failureAlertDescription,
                  actions: [yesAction, noAction])
    }
    
    func showRedirectAlert(with message: String) {
        let openAction = UIAlertAction(title: L10n.QRScanner.redirectOpenTitle, style: .default) { [weak viewController] _ in
            if let url = URL(string: message) {
                viewController?.dismiss(animated: true) {
                    UIApplication.shared.open(url)
                }
            } else {
                viewController?.dismiss(animated: true)
            }
        }
        let copyAction = UIAlertAction(title: L10n.QRScanner.redirectCopyTitle, style: .default) { [weak viewController] _ in
            viewController?.dismiss(animated: true) {
                UIPasteboard.general.string = message
            }
        }
        showAlert(title: L10n.QRScanner.redirectTitle, message: message, actions: [openAction, copyAction])
    }
}
