//
//  AppInstructionLaunch.swift
//
//  Created by Vladimir Malakhov on 27/06/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import Foundation

enum AppInstructionLaunchState {
    
    case `default`
    case authAttempt
    case authSuccess
    case authError
}

typealias RequriedAppInstruction = () -> ()
typealias OptionalAppInstruction = () -> ()

protocol AppInstructionLaunchProtocol {
    
    var authBioState: AppAuthenticationState? { set get }
    var authPinState: AppAuthenticationState? { set get }
    func instruction(required: @escaping RequriedAppInstruction,
                     optional: @escaping OptionalAppInstruction)
}

final class AppInstructionLaunch: AppInstructionLaunchProtocol {
    
    var authBioState: AppAuthenticationState? {
        didSet {
            if oldValue != authBioState {
                updateBioAuthState()
            }
        }
    }
    
    var authPinState: AppAuthenticationState? {
        didSet {
            if oldValue != authPinState {
                updatePinAuthState()
            }
        }
    }
    
    private var instruction: AppInstructionLaunchState = .authAttempt
    
    func instruction(required: @escaping RequriedAppInstruction,
                     optional: @escaping OptionalAppInstruction) {
        switch instruction {
        case .authSuccess:
            resetToDefault()
        case .default:
            optional()
        case .authAttempt:
            break
        case .authError:
            break
        }
        required()
    }
}

private extension AppInstructionLaunch {
    
    // в один метод
    func updateBioAuthState() {
        
        guard let state = authBioState else {
            return
        }
        
        switch state {
        case .attempt: instruction = .authAttempt
        case .success: instruction = .authSuccess
        case .error: instruction = .authError
        }
    }
    
    func updatePinAuthState() {
        
        guard let state = authPinState else {
            return
        }
        
        switch state {
        case .attempt: instruction = .authAttempt
        case .success: instruction = .default
        case .error: instruction = .authError
        }
    }
    
    func resetToDefault() {
        instruction = .default
    }
}
