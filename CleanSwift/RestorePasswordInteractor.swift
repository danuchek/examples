import UIKit

protocol RestorePasswordBusinessLogic: class {
    func initialSetup(request: RestorePassword.InitialSetup.Request)
    func restore(request: RestorePassword.Restore.Request)
}

protocol RestorePasswordDataStore: class {
    var email: String? { get set }
}

final class RestorePasswordInteractor: RestorePasswordBusinessLogic, RestorePasswordDataStore {
    var presenter: RestorePasswordPresentationLogic?
    var apiProvider: ApiProvider?

    var email: String?

    // MARK: - RestorePasswordBusinessLogic

    func initialSetup(request: RestorePassword.InitialSetup.Request) {
        let formFields = RestorePassword.FormFields(email: email ?? "")
        let formErrors = RestorePassword.FormErrors()
        let response = RestorePassword.Restore.Response(formFields: formFields, formErrors: formErrors)
        presenter?.presentRestore(response: response)
    }

    func restore(request: RestorePassword.Restore.Request) {
        if let formErrors = validate(formFields: request.formFields) {
            let response = RestorePassword.Restore.Response(formFields: request.formFields, formErrors: formErrors)
            presenter?.presentRestore(response: response)
        } else {
            restore(email: request.formFields.email, successAction: request.successAction)
        }
    }

    // MARK: - Private methods

    private func restore(email: String, successAction: @escaping ActionFunc) {
        let responseHud = RestorePassword.Indication.Response(indication: IndicationState(type: .hud))
        presenter?.indicate(response: responseHud)

        let target: ApiTarget = .forgetPassword(email: email)
        let responseType = ApiData<BaseResponse>.self
        apiProvider?.requestTarget(target, for: responseType) { [weak self] result in
            guard let self = self else {
                return
            }

            let indicationResponse = RestorePassword.Indication.Response(indication: nil)
            self.presenter?.indicate(response: indicationResponse)

            switch result {
            case .success:
                let action = UIAlertAction(title: L10n.Alert.buttonTitleGood, style: .cancel, handler: { _ in
                    successAction()
                })

                let response = RestorePassword.Alert.Response(
                    title: L10n.RestorePassword.alertTitleSuccess,
                    message: L10n.RestorePassword.alertMessageSuccess,
                    actions: [action]
                )
                self.presenter?.alert(response: response)
            case let .failure(error):
                let response = RestorePassword.Alert.Response(
                    title: L10n.Alert.defaultTitle,
                    message: !error.title.isEmpty ? error.title : L10n.Alert.defaultMessage,
                    actions: [UIAlertAction(title: L10n.Alert.buttonTitleCancel, style: .cancel)]
                )
                self.presenter?.alert(response: response)
            }
        }
    }

    private func validate(formFields: RestorePassword.FormFields) -> RestorePassword.FormErrors? {
        var formErrors = RestorePassword.FormErrors()
        formErrors.emailError = formFields.email.validate(type: .email)
        return formErrors != RestorePassword.FormErrors() ? formErrors : nil
    }
}
