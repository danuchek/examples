import UIKit

enum RestorePassword {

    struct FormFields {
        var email: String
    }

    struct FormErrors: Equatable {
        var emailError: String

        init() {
            emailError = ""
        }
    }

    // MARK: - Use cases

    enum Indication {
        struct Request {}
        struct Response {
            var indication: IndicationState?
        }
        struct ViewModel {
            var indication: IndicationViewModel?
        }
    }

    enum Alert {
        struct Response {
            var title: String?
            var message: String?
            var actions: [UIAlertAction]
        }
    }

    enum InitialSetup {
        struct Request {}
    }

    enum Restore {
        struct Request {
            var formFields: FormFields
            var successAction: ActionFunc
        }
        struct Response {
            var formFields: FormFields
            var formErrors: FormErrors
        }
        struct ViewModel {
            var formFields: FormFields
            var formErrors: FormErrors
        }
    }
}
