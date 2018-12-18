//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import UIKit

protocol EXAAppNavigationDelegate: class {
    func resetWalletAndStartNew()
    func showWalletAfterCreate(_ isRestored: Bool)
    func showDashboard()
    func showDashboardAfterDelete()
    func showConcreteWallet()
    func nextNavigationStep(_ nc: UINavigationController?, step: WalletSequenceStep)
}

class EXAAppNavigationDispatcher  {
    static let sharedInstance = EXAAppNavigationDispatcher()
    weak var actionDelegate: EXAAppNavigationDelegate?

    func resetWalletAndStartNew() {
        self.actionDelegate?.resetWalletAndStartNew()
    }
    
    func showDashboard() {
        self.actionDelegate?.showDashboard()
    }

    func showWalletAfterCreate(_ isRestored: Bool = false) {
        guard let theMeta = AppState.sharedInstance.walletsMetaInfo else {
            self.actionDelegate?.showDashboard()
            return
        }
        
        if theMeta.count == 1 {
            self.actionDelegate?.showWalletAfterCreate(isRestored)
        } else {
            self.actionDelegate?.showDashboard()
        }
    }

    func showDashboardAfterDelete() {
        self.actionDelegate?.showDashboardAfterDelete()
    }

    func showConcreteWallet() {
        self.actionDelegate?.showConcreteWallet()
    }

    func nextNavigationStep(_ nc: UINavigationController?, step: WalletSequenceStep) {
        self.actionDelegate?.nextNavigationStep(nc, step: step)
    }
}
