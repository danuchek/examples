import UIKit

protocol RestorePasswordDisplayLogic: class {
    func indicate(viewModel: RestorePassword.Indication.ViewModel)
    func alert(viewModel: AlertViewModel)
    func displayRestore(viewModel: RestorePassword.Restore.ViewModel)
}

final class RestorePasswordViewController: ParentViewController {
    var interactor: RestorePasswordBusinessLogic?
    var router: (RestorePasswordRoutingLogic & RestorePasswordDataPassing)?

    private let infoLabel = UILabel()
    private let emailTextField = SkyFloatingLabelTextField()
    private let restoreButton = Button(title: L10n.RestorePassword.buttonTitleRestore, style: .red)

    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = RestorePasswordInteractor()
        let presenter = RestorePasswordPresenter()
        let router = RestorePasswordRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.apiProvider = Dependencies.shared.apiProvider
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - Life cycle

    required init?(coder _: NSCoder) {
        fatalError("NSCoder not supported")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel.textAlignment = .center
        infoLabel.textColor = .stackGrey
        infoLabel.numberOfLines = 0
        infoLabel.set(text: L10n.RestorePassword.labelInfo, font: .sfRegular(size: 13), minimumLineHeight: 18)

        emailTextField.delegate = self
        emailTextField.title = L10n.RestorePassword.fieldTitleEmail
        emailTextField.placeholder = L10n.RestorePassword.fieldTitleEmail
        emailTextField.keyboardType = .emailAddress

        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        restoreButton.height(52)

        let stackView = UIStackView(arrangedSubviews: [infoLabel, emailTextField, restoreButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        view.sv(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stackView.fillHorizontally(m: 31)
        stackView.Width == emailTextField.Width
        stackView.Width == restoreButton.Width

        stackView.setCustomSpacing(20, after: infoLabel)
        stackView.setCustomSpacing(30, after: emailTextField)

        addCloseKeyboardGestureRecognizer()

        let request = RestorePassword.InitialSetup.Request()
        interactor?.initialSetup(request: request)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailTextField.becomeFirstResponder()
    }

    // MARK: - Configure

    override func configure(titleLabel: UILabel) {
        super.configure(titleLabel: titleLabel)
        titleLabel.textColor = .black
        titleLabel.text = L10n.RestorePassword.title
    }

    override func configure(headerView: ParentViewControllerHeader) {
        super.configure(headerView: headerView)
        headerView.update(barBackgroundStyle: .white)
    }

    // MARK: - Actions

    @objc
    private func restoreTapped() {
        view.endEditing(true)

        let formFields = RestorePassword.FormFields(
            email: emailTextField.text ?? ""
        )
        let request = RestorePassword.Restore.Request(
            formFields: formFields,
            successAction: { [weak self] in
                self?.router?.routeBack()
            })
        interactor?.restore(request: request)
    }
}

// MARK: - UITextFieldDelegate

extension RestorePasswordViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.errorMessage = ""
        }
        return true
    }
}

// MARK: - AuthDisplayLogic

extension RestorePasswordViewController: RestorePasswordDisplayLogic {

    func indicate(viewModel: RestorePassword.Indication.ViewModel) {
        indicationHelper.update(viewModel: viewModel.indication)
    }

    func alert(viewModel: AlertViewModel) {
        router?.routeToAlert(viewModel: viewModel)
    }

    func displayRestore(viewModel: RestorePassword.Restore.ViewModel) {
        emailTextField.text = viewModel.formFields.email
        emailTextField.errorMessage = viewModel.formErrors.emailError
    }
}
