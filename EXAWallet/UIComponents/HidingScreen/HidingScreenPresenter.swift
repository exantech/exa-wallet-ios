//
//  HidingScreenPresenter.swift
//
//  Created by Vladimir Malakhov on 20/06/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

protocol HidingScreenPresenterProtocol {
    func present(with window: UIWindow?)
    func dismiss()
}

final class HidingScreenPresenter: HidingScreenPresenterProtocol {
    
    private var hidingView: HidingScreenView?
    
    func present(with window: UIWindow?) {
        
        guard let window = window, !AppState.sharedInstance.isBiometryPresent else {
            return
        }
        hidingView = HidingScreenView(frame: window.frame)
        if let view = hidingView {
            window.addSubview(view)
        }
    }
    
    func dismiss() {
        guard let view = hidingView else {
            return
        }
        view.removeFromSuperview()
        hidingView = nil
    }
}

