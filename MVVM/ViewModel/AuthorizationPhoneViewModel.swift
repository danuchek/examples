//
//  PhoneEnterViewModel.swift
//
//  Created by Daniil on 29.07.2020.
//

import RxSwift
import RxCocoa
import Moya

protocol AuthorizationPhoneViewModelProtocol: AnyObject {
    var countryListSubject: PublishRelay<[CountryModel]> { get set }
    /// Обсервер номера телефона
    var phoneNumber: BehaviorRelay<String> { get set }
    /// Обсервер отображения лоадера
    var isNeedShowError: Observable<String> { get }
    /// Обсервер перехода на экран ввода смс
    var isCodeSending: Observable<Bool> { get }
    /// Авторизация/Регистрация по номеру телефона
    func authorizationWithPhone()
    /// Запрос на получение списка стран
    func getCountyList()
}

final class AuthorizationPhoneViewModel: AuthorizationPhoneViewModelProtocol {
    
    //MARK: - Dependencies
    
    /// Сервис авторизации
    private var authotizationService: AuthorizationServiceProtocol!
    
    //MARK: - Internal properties
    var countryListSubject = PublishRelay<[CountryModel]>()
    /// Обсервер отображения лоадера
    private var isNeedShowErrorAllert = PublishRelay<String>()
    /// Cабджект перехода на экран ввода смс
    private var didSendCodeSubject = PublishRelay<Bool>()
    /// Обсервер номера телефона
    var phoneNumber = BehaviorRelay<String>(value: "")
    /// Обертка сабджекта для обновления активити индикатора
    var isNeedShowError: Observable<String> {
        return isNeedShowErrorAllert.asObservable()
    }
    /// Обертка сабджката переход на экран ввода смс
    var isCodeSending: Observable<Bool> {
        return didSendCodeSubject.asObservable()
    }
    /// Диспоз бег
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    
    /// Инициализация вьюмодели
    /// - Parameter authotizationService: Сервис авторизации
    init(authotizationService: AuthorizationServiceProtocol) {
        self.authotizationService = authotizationService
    }
}

//MARK: - AuthorizationPhoneViewModelExtension

extension AuthorizationPhoneViewModel {
    
    func authorizationWithPhone() {
        authotizationService.authorizationWithSmsConfirmation(phone: phoneNumber.value)
            .subscribe(
                onSuccess: { [weak self] _ in
                    guard let self = self else { return }
                    self.didSendCodeSubject.accept(true)
                }
                ,onFailure: { [weak self] error in
                    guard let self = self, let error = error as? MoyaError else { return }
                    if let data = try? error.response?.map(AuthorizationResponseModel.self) {
                        self.isNeedShowErrorAllert.accept(data.error ?? "")
                    }
                })
            .disposed(by: disposeBag)
    }
    
    func getCountyList() {
        authotizationService.getCountryList()
            .map({ $0.countries ?? [] })
            .subscribe(onSuccess: { [weak self] modelResponse in
                guard let self = self else { return }
                let model = modelResponse.map({ CountryModel(mobileCode: $0.mobileCode, mobileMask: $0.mobileMask, id: $0.id, name: $0.name, code: $0.code, city: .none, images: $0.images) })
                self.countryListSubject.accept(model)
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
}
