//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

enum AppRouterFlowType {
    case newWallet
    case currentWallet
    case concreteWallet
    case continueMaster
    case `default`
}

enum WalletSequenceStep {
    case chooseOption
    case createWallet
    case restoreWallet
    case createCommonWallet
    case joinSharedWallet
    case joinSharedWalletAfterInviteCode(inviteCode: InviteCode)
    case participantScreen
    case participantScreenAfterCreate
    case inviteParticipants
    case inviteParticipantsAfterCreate
    case fillMetaInfo
    case showPassphrase
    case validatePassphrase
    case postValidationPassphrase
}

protocol AppRouterProtocol {

    //var currentFlow: AppRouterFlowType { get }

    func present(with type: AppRouterFlowType)
    /*func successMessage(_ message: String)

    func presentHidingScreen()
    func dismissHidingScreen()*/
    func nextNavigationStep(_ nc: UINavigationController?, step: WalletSequenceStep)
}

final class AppRouter: PinCodeDismissDelegate {

    var currentFlow: AppRouterFlowType = .default

    private let window: UIWindow?
    private let fabric = AppUIFabric()

    init(window: UIWindow?) {
        self.window = window
        present(with: currentFlow)
    }


    func onDismiss() {
        presentCurrentWallet()
    }
}

extension AppRouter: AppRouterProtocol {

    func present(with type: AppRouterFlowType) {
        switch type {
        case .newWallet:
            presentNewWallet()
        case .currentWallet:
            presentCurrentWallet()
        case .concreteWallet:
            presentConcreteWallet()
        case .continueMaster:
            noop()
        case .default:
            presentDefault()
        }
    }

    func nextNavigationStep(_ nc: UINavigationController?, step: WalletSequenceStep) {
        nc?.pushViewController(fabric.createUIStep(step), animated: true)
    }
}

private extension AppRouter {

    func presentNewWallet() {
        let interface = fabric.createNewWalletUI()
        setRoot(interface)
        currentFlow = .newWallet
    }

    func presentCurrentWallet() {
        AppState.sharedInstance.currentState = .normal
        let interface = fabric.createMainUI()
        setRoot(interface)
        currentFlow = .currentWallet
    }

    func presentPinCode() {
        let pincodeService = PinCodeViewController()
        guard let _ = pincodeService.present(with: .create, delegate: self) else {
            print("AppNavigation: Error unable to load pinController")
            return
        }
    }

    func presentConcreteWallet() {
        let interface = fabric.createConcreteWalletUI()
        setRoot(interface)
        currentFlow = .currentWallet
    }

    func presentDefault() {
        window?.rootViewController = RootViewController()
        currentFlow = .default
    }
}

private extension AppRouter {

    func setRoot(_ controller: UIViewController) {
        window?.rootViewController = controller
    }
}
