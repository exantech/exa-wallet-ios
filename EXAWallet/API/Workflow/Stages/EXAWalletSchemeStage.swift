//
// Created by Igor Efremov on 2019-02-25.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

protocol SchemeCompletionDelegate: class {
    func completed(scheme: SharedWalletScheme)
    func failure(error: String)
}

class EXAWalletSchemeStage: BaseMultisignatureWalletWorkflowStage {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: WalletSchemeAPI?
    private var _callback: WalletSchemeAPIResultCallbackImpl?
    private var _inviteCode: String?
    private var _publicKey: String?

    private var _schemeMethod: WalletSchemeMethod = .by_invite_code
    private var _info: String?

    override var type: MultisigStage {
        return .wallet_scheme
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Wallet Scheme"
    }

    override var completedMessage: String {
        return "Got wallet scheme"
    }

    init(callback: WalletSchemeAPIResultCallbackImpl) {
        _callback = callback
    }

    func setupInfo(_ info: String?) {
        _info = info
    }

    func setupSchemeMethod(_ schemeMethod: WalletSchemeMethod) {
        _schemeMethod = schemeMethod
    }

    override func execute() {
        _api = WalletSchemeAPIImpl(resultCallback: _callback)

        guard let theInfo = _info else {
            print("Info for scheme method isn't defined")
            return
        }

        guard let api = _api else { return }

        print("Execute \(name) Stage")

        switch _schemeMethod {
        case .by_invite_code:
            api.walletScheme(inviteCode: InviteCodeParam(theInfo))
        case .by_public_key:
            api.walletScheme(publicKey: PublicKeyParam(theInfo))
        }
    }

    deinit {
        print("deinit EXAWalletSchemeStage")
    }
}
