//
//  AppNavigationPoint.swift
//
//  Created by Vladimir Malakhov on 05/07/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import Foundation

enum AppNavigationPoint {
    case auth, wallet, new
}

final class AppNavigationPointSequence {
    
    var timer: PincodeTimer
    
    // TODO: fix
    var point: AppNavigationPoint {
        get {
            if isWalletExists() {
                let handlePincode = isHandlePincode()
                if handlePincode {
                    if timer.isNeededShown {
                        return .auth
                    } else {
                        return .wallet
                    }
                } else {
                    return .wallet
                }
            } else {
                return .new
            }
        }
    }
    
    init(_ timer: PincodeTimer) {
        self.timer = timer
    }
    
    func startObserveBackgroundTime() {
        timer.saveQuitTime()
    }
}

private extension AppNavigationPointSequence {
    
    func isHandlePincode() -> Bool {
        guard (UserDefaults.standard.string(forKey: PinCodeConstants.kPincodeDefaultsKey) != nil) else {
            return false
        }
        return true
    }

    func isWalletExists() -> Bool {
        guard let theMetaInfo = AppState.sharedInstance.walletsMetaInfo else { return false }
        return theMetaInfo.count > 0
    }
}
