//
//  PhoneEnterViewController.swift
//
//  Created by Daniil on 29.07.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AuthorizationPhoneView: BaseViewController {
    
    //MARK: - UI
    
    private let backgroundView = UIView()
    /// Текст филд с вводом номера телефона
    private var phoneEnterTextField = PhoneTextField()
    /// Заголовок лейбл
    private lazy var titleLabel = makeTitleLabel()
    /// Подзаголовок лейбл
    private lazy var subTitleLabel = makeSubTitleLabel()
    /// Кнопка продолджить
    private lazy var nextButton = makeNextButton()
    /// Кнопка продолжить без регистрации
    private lazy var skipButton = makeSkipButton()
    /// Персональные данные лейбл
    private lazy var termsLabel = makeTermsLabel()
    /// Выпадающий список выбора маски телефона
    private lazy var countryView = DropDownCountryView()
    /// Констрейнт кнопки продолжить без регистрации
    private var skipButtonBottomConstraint: NSLayoutConstraint!
    /// Констрейнт текстфилда с номером телефона
    private var textFieldBottomConstraint: NSLayoutConstraint!
    
    //MARK: - Dependencies
    
    ///  Вью модель
    var viewModel: AuthorizationPhoneViewModelProtocol!
    
    //MARK: - Internal properties
    
    /// Тап жестур на вью
    private var endEditingTap: UITapGestureRecognizer!
    /// Диспоз бег рx корзина для очистки объекта
    private let disposeBag = DisposeBag()
    
    //MARK: - Callbacks
    
    /// Код успешно оправлен, переход к экрану ввода кода
    var didSendCode: ((String) -> Void)?
    /// Колбек продолжить без регистрации
    var startWithoutRegistrartion: (() -> Void)?
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.getCountyList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNotifications()
    }
}

//MARK: - AuthorizationPhoneViewExtension PrivateFunc

extension AuthorizationPhoneView {
    
    private func bind() {
        nextButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.showLoader()
                self.viewModel.authorizationWithPhone()
            }
            .disposed(by: disposeBag)
        
        phoneEnterTextField.phoneNumber
            .filter({ $0.count > 4 })
            .subscribe(
                onNext: { [weak self] phoneNumber in
                    guard let self = self else { return }
                    self.viewModel.phoneNumber.accept(phoneNumber)
                    self.nextButton.isEnabled = true
                })
            .disposed(by: disposeBag)
        
        phoneEnterTextField.isNeedShowButton
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                self.nextButton.isEnabled = event
            })
            .disposed(by: disposeBag)
        
        phoneEnterTextField.countryDidTapped = { [weak self] in
            guard let self = self else { return }
            self.configureCountryView()
        }
        
        countryView.didSelectMaskPhone = { [weak self] model in
            guard let self = self else { return }
            self.phoneEnterTextField.updatePhoneCode.accept(model)
            self.removeBackgroundView()
        }
        
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.startWithoutRegistrartion?()
            })
            .disposed(by: disposeBag)
        
        viewModel.isNeedShowError
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                self.hideLoader()
                UIAlertController
                    .present(in: self, title: "Ошибка", message: event.element, style: .alert, actions: [UIAlertController.AlertAction.action(title: "Ок")])
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        viewModel.isCodeSending
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hideLoader()
                self.didSendCode?(self.viewModel.phoneNumber.value)
            })
            .disposed(by: disposeBag)
        
        viewModel.countryListSubject
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.countryView.countryModel.accept(model)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            NSLayoutConstraint.deactivate([
                skipButtonBottomConstraint,
                textFieldBottomConstraint
            ])
            skipButtonBottomConstraint = skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(keyboardSize.height + 16))
            textFieldBottomConstraint = phoneEnterTextField.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -50)
            
            NSLayoutConstraint.activate([
                skipButtonBottomConstraint,
                textFieldBottomConstraint
            ])
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.view.setNeedsLayout()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        NSLayoutConstraint.deactivate([
            skipButtonBottomConstraint,
            textFieldBottomConstraint
        ])
        skipButtonBottomConstraint = skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -23)
        textFieldBottomConstraint = phoneEnterTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([
            skipButtonBottomConstraint,
            textFieldBottomConstraint
        ])
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.view.setNeedsLayout()
        }
    }
    
    @objc private func termsDidTap(_ gesture: UITapGestureRecognizer) {
        let range = ((termsLabel.text ?? "") as NSString).range(of: "Пользовательского соглашения")
        
        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: range) {
            
        }
    }
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    private func configureCountryView() {
        view.endEditing(true)
        if let endEditingTap = self.endEditingTap {
            endEditingTap.cancelsTouchesInView = false
            self.endEditingTap = endEditingTap
        }
        view.addSubviews(backgroundView ,countryView)
        backgroundView.frame = view.frame
        countryView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        backgroundView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 0.85
            
            NSLayoutConstraint.activate([
                self.countryView.topAnchor.constraint(equalTo: self.phoneEnterTextField.bottomAnchor, constant: 2),
                self.countryView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.countryView.trailingAnchor.constraint(equalTo: self.phoneEnterTextField.phoneCodeView.trailingAnchor),
                self.countryView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }, completion: nil)
    }
    
    @objc func removeBackgroundView() {
        if let endEditingTap = endEditingTap {
            endEditingTap.cancelsTouchesInView = true
            self.endEditingTap = endEditingTap
        }
        backgroundView.removeFromSuperview()
        countryView.removeFromSuperview()
    }
}

//MARK: - AuthorizationPhoneViewExtension UI

extension AuthorizationPhoneView {
    
    private func makeNextButton() -> CLButton {
        let button = CLButton(arrowStyle: .none, buttonStyle: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setTitle("Далее", for: .normal)
        button.titleLabel?.font = Fonts.GothamPro.bold.font(size: 17)
        return button
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = Fonts.GothamPro.bold.font(size: 17)
        label.textColor = Resources.Colors.Grayscale.white.color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Вход"
        return label
    }
    
    private func makeSubTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = Fonts.GothamPro.regular.font(size: 15)
        label.textColor = Resources.Colors.Grayscale.white.color
        label.text = "Введите номер"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeSkipButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Продолжить без регистрации", for: .normal)
        button.setTitleColor(Resources.Colors.Grayscale.white.color, for: .normal)
        button.titleLabel?.font = Fonts.GothamPro.bold.font(size: 17)
        return button
    }
    
    private func makeTermsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.configureAuthTermsText()
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsDidTap(_:))))
        return label
    }
    
    private func setupUI() {
        tabBarController?.tabBar.isHidden = true
        
        let removeBackViewTap = UITapGestureRecognizer(target: self, action: #selector(removeBackgroundView))
        backgroundView.addGestureRecognizer(removeBackViewTap)
        endEditingTap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(endEditingTap)
        
        view.backgroundColor = Resources.Colors.Grayscale.black.color
        view.addSubviews(titleLabel, subTitleLabel, phoneEnterTextField, nextButton, termsLabel, skipButton)
        
        phoneEnterTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldBottomConstraint = phoneEnterTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            textFieldBottomConstraint,
            phoneEnterTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            phoneEnterTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            phoneEnterTextField.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: termsLabel.topAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 46)
        ])
        
        NSLayoutConstraint.activate([
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            termsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            termsLabel.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -16)
        ])
        
        skipButtonBottomConstraint = skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -23)
        NSLayoutConstraint.activate([
            skipButtonBottomConstraint,
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 46),
        ])
    }
}
