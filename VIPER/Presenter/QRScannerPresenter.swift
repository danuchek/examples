//
//  QRScannerPresenter.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

final class QRScannerPresenter {
    private let router: QRScannerRouting
    private let interactor: QRScannerInteractorInput
    private weak var view: QRScannerPresenterOutput?
    private let completion: TextHandler

    init(_ router: QRScannerRouting,
         _ interactor: QRScannerInteractorInput,
         _ view: QRScannerPresenterOutput,
         _ completion: @escaping TextHandler) {
        self.router = router
        self.interactor = interactor
        self.view = view
        self.completion = completion
    }

    func viewDidLoad() {
        interactor.attach(self)
        view?.setupUI()
    }
}

extension QRScannerPresenter: QRScannerPresenterInput {
    func didSuccessScanning(_ code: String) {
        guard code.contains(Constants.Url.dynamicLinksDomainURIPrefix) else {
            router.showRedirectAlert(with: code)
            view?.stopScanning()
            return
        }
        
        completion(code)
        router.dismiss()
    }
    
    func didFailureScanning() {
        router.shouldRescan { [weak view] result in
            if result {
                view?.rescan()
            }
        }
    }
    
    func closeScannerView() {
        router.dismiss()
    }
}

extension QRScannerPresenter: QRScannerInteractorOutput {}
