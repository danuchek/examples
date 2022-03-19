//
//  AuthorizationPhoneAssembler.swift
//
//  Created by Daniil on 29.07.2020.
//

import Foundation

final class AuthorizationPhoneAssembler {
    static func createModule() -> AuthorizationPhoneView {
        let viewController = AuthorizationPhoneView()
        let viewModel = AuthorizationPhoneViewModel(authotizationService: AuthorizationService())
        viewController.viewModel = viewModel
        return viewController
    }
}
