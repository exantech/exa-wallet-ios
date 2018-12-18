//
//  AppBioAuthViewPresenter.swift
//
//  Created by Vladimir Malakhov on 13/07/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

final class AppBioAuthViewPresenter {
    
    var dismissHandler: DefaultCallback?
    
    private var view: AppBioAuthView?
    private var auth = AppBioAuthentication()
    
    init() {
        applyViewStyle()
        subscriptForViewEvents()
    }
}

extension AppBioAuthViewPresenter {
    
    func present() {
        guard let view = view else {
            return
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(view, animated: false, completion: nil)
    }
    
    private func dismiss() {
        view?.dismiss(animated: false, completion: { [weak self] in
            self?.dismissHandler?()
        })
    }
}

private extension AppBioAuthViewPresenter {
    
    func applyViewStyle() {
        var style: AppBioAuthViewStyle = .touch
        if auth.isFaceID() {
            style = .face
        }
        view = AppBioAuthView(style)
    }
    
    func subscriptForViewEvents() {
        view?.onAccessButtonTapped = {
            AppBioAuthenticationControl().work(true)
            self.dismiss()
        }
        
        view?.onSkipButtonTapped = {
            self.dismiss()
        }
    }
}
