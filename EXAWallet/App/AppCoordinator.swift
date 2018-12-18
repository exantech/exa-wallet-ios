//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum AppCoordinatorState {

    case `default`
    case regular
    case wallet
}

protocol AppCoordinatorProtocol {

    func setupApp(with type: AppCoordinatorState)
    func updateUserFlow(with type: AppCoordinatorState)
}

final class AppCoordinator {

    private var isDefaultFlowUpdateProceded = true
    private var isDefaultDataUpdateProceded = true

    //private let container : AppContainerProtocol
    private let navigation: AppNavigationProtocol

    init(appNavigation: AppNavigationProtocol) {
        self.navigation = appNavigation
    }
}

extension AppCoordinator: AppCoordinatorProtocol {

    func updateUserFlow(with type: AppCoordinatorState) {
        switch type {
        case .default:
            navigation.defaultUserFlow()
        case .regular:
            DispatchQueue.main.async {
                self.navigation.regularUserFlow()
            }
        case .wallet:
            navigation.openConcreteWallet()
        }
    }

    func setupApp(with type: AppCoordinatorState) {
        switch type {
        case .default:
            defaultAppSetup()
        case .regular, .wallet:
            noop()
        }
    }
}

private extension AppCoordinator {

    func defaultAppSetup() {
        loadWallet(for: .default)
    }

    func loadWallet(for state: AppCoordinatorState) {
        WalletManager.shared.loadWallets()
        if state == .default {
            self.updateUserFlow(with: .default)
        }
    }
}
