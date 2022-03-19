import UIKit

protocol RestorePasswordRoutingLogic: CommonRouter {
    func routeBack()
}

protocol RestorePasswordDataPassing: class {
    var dataStore: RestorePasswordDataStore? { get }
}

final class RestorePasswordRouter: NSObject, RestorePasswordRoutingLogic, RestorePasswordDataPassing {
    weak var viewController: RestorePasswordViewController?
    var dataStore: RestorePasswordDataStore?
    var fromController: UIViewController? {
        viewController
    }

    // MARK: - Routing

    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
