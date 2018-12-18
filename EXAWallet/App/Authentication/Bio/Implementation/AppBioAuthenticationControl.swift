//
//  AppBioAuthenticationControl.swift
//
//
//  Created by Vladimir Malakhov on 10/07/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

final class AppBioAuthenticationControl {
    
    private static let controlValue = "AppBioAuthenticationControl.Control.Value"
    private let standard = UserDefaults.standard
    
    func value() -> Bool {
        return standard.bool(forKey: AppBioAuthenticationControl.controlValue)
    }
    
    func work(_ value: Bool) {
        standard.set(value, forKey: AppBioAuthenticationControl.controlValue)
    }
}
