import UIKit

protocol RestorePasswordPresentationLogic: class {
    func indicate(response: RestorePassword.Indication.Response)
    func alert(response: RestorePassword.Alert.Response)
    func presentRestore(response: RestorePassword.Restore.Response)
}

final class RestorePasswordPresenter: RestorePasswordPresentationLogic {

    weak var viewController: RestorePasswordDisplayLogic?

    // MARK: - RestorePasswordPresentationLogic

    func indicate(response: RestorePassword.Indication.Response) {
        var indicationViewModel: IndicationViewModel?
        if let indication = response.indication {
            indicationViewModel = IndicationViewModel(
                indication: indication,
                type: indication.type,
                image: nil,
                message: indication.networkError?.title ?? "",
                action: indication.action
            )
        }
        let viewModel = RestorePassword.Indication.ViewModel(indication: indicationViewModel)
        viewController?.indicate(viewModel: viewModel)
    }

    func alert(response: RestorePassword.Alert.Response) {
        viewController?.alert(viewModel: AlertViewModel(title: response.title, message: response.message, actions: response.actions))
    }

    func presentRestore(response: RestorePassword.Restore.Response) {
        let viewModel = RestorePassword.Restore.ViewModel(
            formFields: response.formFields,
            formErrors: response.formErrors
        )
        viewController?.displayRestore(viewModel: viewModel)
    }
}
