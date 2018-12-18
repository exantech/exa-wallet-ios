//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

typealias DefaultCallback = () -> ()

enum NavigationState {
    case standard, deepLink
}

protocol AppNavigationProtocol {
    func defaultUserFlow()
    func regularUserFlow()
    func startUserFlow()
    func openConcreteWallet()

    var onUpdatedAuthState: AppAuthenticationStateHandler? { get set }
}

final class AppNavigation {
    var state: NavigationState = .standard
    var onUpdatedAuthState: AppAuthenticationStateHandler?
    private let appRouter: AppRouterProtocol
    private let sequence: AppNavigationPointSequence
    private var authentication = AppAuthentication() as AppAuthenticationProtocol
    private let hiddingScreen: HidingScreenPresenterProtocol
    private var messageText = ""

    init(appRouter: AppRouterProtocol, sequence: AppNavigationPointSequence, hiddingScreen: HidingScreenPresenterProtocol) {
        self.appRouter = appRouter
        self.sequence = sequence
        self.hiddingScreen = hiddingScreen
        defaultSetup()
    }
}

extension AppNavigation: AppNavigationProtocol {

    func defaultUserFlow() {
        defer {
            self.hiddingScreen.dismiss()
        }

        let point = sequence.point
        guard self.state == NavigationState.standard else {
            return
        }
        switch point {
        case .auth:
            self.presentAuth(with: .validate) {}
        case .wallet:
            self.presentMain()
        case .new:
            //self?.presentMainController()
                //noop()
            self.showStartScreen()
        }
    }

    func regularUserFlow() {
        presentAuth(with: .validate, onPresent: { [weak self] in
            self?.hiddingScreen.dismiss()
        })
    }

    func startUserFlow() {
        defer {
            self.hiddingScreen.dismiss()
        }

        let selectedFlow: AppRouterFlowType
        if .creating == AppState.sharedInstance.currentState {
            selectedFlow = .continueMaster
        } else {
            selectedFlow = isWalletExists() ? .currentWallet : .newWallet
        }

        appRouter.present(with: selectedFlow)
    }

    func openConcreteWallet() {
        appRouter.present(with: .concreteWallet)
    }

    func presentAuth(with mode: PinCodeMode, onPresent: @escaping DefaultCallback) {
        authentication.proceed(with: mode)
        authentication.onPresentPin = { onPresent() }
        authentication.onCancelCreate = { [weak self] in
            self?.startUserFlow()
        }
        authentication.state = { [weak self] state, type in
            self?.onUpdatedAuthState?(state, type)
            switch state {
            case .attempt:
                break
            case .success:
                self?.startUserFlow()
            case .error:
                break
            }
        }
        authentication.onDismissBiometryScreen = { [weak self] in
            guard let text = self?.messageText, text.length > 0 else { return }
            EXADialogs.showMessage(text, title: EXAAppInfoService.appTitle, buttonTitle: l10n(.commonOk))
        }
    }
}

extension AppNavigation: EXAAppNavigationDelegate {

    func presentMain() {
        /*let builder = MainTabBuilder(wireframe: wireframe)
        main = MainTab(builder)
        main?.select(frame, with: nil as NavigationData?)
        guard let main = main else { return }
        router.setRoot(main)*/
        print("Show Dashboard")
        WalletManager.shared.loadWallets()
        appRouter.present(with: .currentWallet)
    }

    func resetWalletAndStartNew() {
        /*AppState.sharedInstance.walletInfo = nil
        onNeedRemoveData?()
        appRouter.present(with: .newWallet)*/
    }

    func showStartScreen() {
        print("Show Start Screen")
        AppState.sharedInstance.walletsMetaInfo = nil
        appRouter.present(with: .newWallet)
    }

    func showWalletAfterCreate(_ isRestored: Bool) {
        showDashboard()
        presentAuth(with: .create) {}
    }

    func showDashboardAfterDelete() {
        showDashboard()
    }

    func showDashboard() {
        print("Show Dashboard")
        WalletManager.shared.loadWallets()
        appRouter.present(with: .currentWallet)
    }

    func showConcreteWallet() {
        appRouter.present(with: .concreteWallet)
    }

    func nextNavigationStep(_ nc: UINavigationController?, step: WalletSequenceStep) {
        appRouter.nextNavigationStep(nc, step: step)
    }
}

private extension AppNavigation {

    func defaultSetup() {
        EXAAppNavigationDispatcher.sharedInstance.actionDelegate = self
    }

    func isWalletExists() -> Bool {
        guard let theMetaInfo = AppState.sharedInstance.walletsMetaInfo else { return false }
        return theMetaInfo.count > 0
    }
}
