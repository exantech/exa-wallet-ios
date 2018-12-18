//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

private struct UISource {

    struct Controller {

        static let main = "walletTabViewController"
        static let newWallet = "startNewWalletController"
    }

    struct Storyboard {

        static let main = "Main"
    }
}

class AppUIFabric {

    func createMainUI() -> UIViewController {
        return EXAUINavigationController(rootViewController: DashboardViewController())
    }

    func createConcreteWalletUI() -> UIViewController {
        return EXAUINavigationController(rootViewController: EXAWalletTabViewController())
    }

    func createNewWalletUI() -> UIViewController {
        return EXAUINavigationController(rootViewController: MainViewController())
    }

    func createPersonalWalletUI() -> UIViewController {
        return WalletMetaInfoWalletViewController(.createPersonal)
    }

    func createCommonWalletUI() -> UIViewController {
        return WalletMetaInfoWalletViewController(.createShared)
    }

    func enterInviteCodeUI() -> UIViewController {
        return EnterInvitationViewController()
    }

    func inviteParticipantsUI(afterCreate: Bool) -> UIViewController {
        return InviteParticipantsViewController(afterCreate: afterCreate)
    }

    func joinSharedWalletUI(afterCreate: Bool) -> UIViewController {
        return JoinSharedWalletViewController(afterCreate: afterCreate)
    }

    func restoreWalletUI() -> UIViewController {
        return RestoreWalletViewController(.restore)
    }

    func fillWalletMetaInfoUI() -> UIViewController {
        return WalletMetaInfoWalletViewController(.restore)
    }

    func joinWalletMetaInfoUI(_ inviteCode: InviteCode) -> UIViewController {
        return WalletMetaInfoWalletViewController(.joinShared, inviteCode: inviteCode)
    }

    func passPhraseUI() -> UIViewController {
        return PassphraseViewController()
    }

    func validatePassphraseUI() -> UIViewController {
        return ValidatePassphraseViewController()
    }

    func postValidationPassphraseUI() -> UIViewController {
        return PostValidationPassphraseViewController()
    }

    func createUIStep(_ step: WalletSequenceStep) -> UIViewController {
        switch step {
        case .chooseOption:
            return MainViewController()
        case .createWallet:
            return createPersonalWalletUI()
        case .createCommonWallet:
            return createCommonWalletUI()
        case .joinSharedWallet:
            return enterInviteCodeUI()
        case let .joinSharedWalletAfterInviteCode(inviteCode):
            return joinWalletMetaInfoUI(inviteCode)
        case .participantScreen:
            return joinSharedWalletUI(afterCreate: false)
        case .participantScreenAfterCreate:
            return joinSharedWalletUI(afterCreate: true)
        case .inviteParticipants:
            return inviteParticipantsUI(afterCreate: false)
        case .inviteParticipantsAfterCreate:
            return inviteParticipantsUI(afterCreate: true)
        case .restoreWallet:
            return restoreWalletUI()
        case .fillMetaInfo:
            return fillWalletMetaInfoUI()
        case .showPassphrase:
            return passPhraseUI()
        case .validatePassphrase:
            return validatePassphraseUI()
        case .postValidationPassphrase:
            return postValidationPassphraseUI()
        }
    }
}

private extension AppUIFabric {

    func createController(with storyboard: String, controller: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: controller)
    }
}
