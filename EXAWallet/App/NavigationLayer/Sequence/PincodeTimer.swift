//
//  AppPincodeShownService.swift
//
//  Created by Vladimir Malakhov on 07/05/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import Foundation

private struct CacheValueKeys {
    
    static let quitTime  = "kQuitTime"
    static let timeLimit = "kTimeLimit"
}

final class PincodeTimer {
    
    private let cache = UserDefaults.standard
    private var firstLaunchInSession = true
    
    var isNeededShown: Bool {
        
        if firstLaunchInSession {
            return true
        }
        
        guard let quitDate = cache.object(forKey: CacheValueKeys.quitTime) as? Date else {
            return true
        }
        
        let diff  = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: quitDate, to: Date())
        let limit = limitedDate()
        
        guard let diffDate = Calendar.current.date(from: diff), let limitDate = Calendar.current.date(from: limit) else {
            return true
        }
        
        if diffDate > limitDate {
            return true
        } else {
            return false
        }
    }
}

extension PincodeTimer {
    
    func saveQuitTime() {
        
        guard (UserDefaults.standard.string(forKey: PinCodeConstants.kPincodeDefaultsKey) != nil) else {
            return
        }
        
        let quitTime = Date()
        cache.set(quitTime, forKey: CacheValueKeys.quitTime)
        
        firstLaunchInSession = false
    }
    
    func limitedDate() -> DateComponents {
        var limitDate = DateComponents()
        limitDate.month = 0
        limitDate.day = 0
        limitDate.hour = 0
        limitDate.minute = 0
        limitDate.second = 10
        return limitDate
    }
}
