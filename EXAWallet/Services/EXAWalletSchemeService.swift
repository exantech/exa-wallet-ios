//
// Created by Igor Efremov on 2019-03-25.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

enum WalletSchemeMethod: Int {
    case by_invite_code, by_public_key
}

class EXAWalletSchemeService {
    private var _schemeStage: EXAWalletSchemeStage?
    private var _completionAction: ((SharedWalletScheme) -> Void)?
    private var _failureAction: ((String) -> Void)?

    func requestScheme(_ schemeMethod: WalletSchemeMethod, info: String?,
                       completionAction: ((SharedWalletScheme) -> Void)? = nil, failureAction: ((String) -> Void)? = nil) {
        _completionAction = completionAction
        _failureAction = failureAction

        _schemeStage = EXAWalletSchemeStage(callback: WalletSchemeAPIResultCallbackImpl(completionDelegate: self))
        _schemeStage?.setupSchemeMethod(schemeMethod)
        _schemeStage?.setupInfo(info)
        _schemeStage?.execute()
    }
}

extension EXAWalletSchemeService: SchemeCompletionDelegate {

    func completed(scheme: SharedWalletScheme) {
        _completionAction?(scheme)
    }

    func failure(error: String) {
        _failureAction?(error)
    }
}

class WalletSchemeAPIResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = SharedWalletScheme
    weak var _completionDelegate: SchemeCompletionDelegate?

    init(completionDelegate: SchemeCompletionDelegate) {
        _completionDelegate = completionDelegate
    }

    func completed(result: T) {
        print(result)
        _completionDelegate?.completed(scheme: result)
    }

    func failure(error: String) {
        _completionDelegate?.failure(error: error)
    }
}
