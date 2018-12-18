//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MultisigStage: Int {
    case basic, create_wallet, wallet_scheme, pusher, wallet_state, send_extra_multisig, get_extra_multisig, finalize_wallet, check_join, transform
}

protocol MultisignatureWalletAPIResultCallback: class {
    func failure(error: String)
    func completed(result: String)
    func completed(resultArray: [String])
    func completed(stage: MultisigStage)
    func completed(resultJSON: JSON)
}

protocol SharedWalletAPIResultCallback: class {
    associatedtype T
    func failure(error: String)
    func completed(result: T)
}

protocol StageCompletion: class {
    func onStageCompleted(_ info: String?, type: MultisigStage?)
    func onStageCompleted(_ inviteCode: InviteCode, type: MultisigStage?)
    func onStageCompleted(result: [Any]?, type: MultisigStage?)
    func onStageSkipped(result: Bool, reason: String?)

    func onFinishWorkflow()
}

protocol MultisignatureWalletWorkflowStage {
    var name: String { get }
    var type: MultisigStage { get }
    var completedMessage: String { get }
    var status: Bool { get }

    func setupCompletion(_ value: StageCompletion?)
    func execute()
    
    func setupStage(data: [Any]?)

    var inviteStage: Bool { get }
}

class BaseMultisignatureWalletWorkflowStage: MultisignatureWalletWorkflowStage {
    weak var _completion: StageCompletion?

    var type: MultisigStage {
        return .basic
    }

    var name: String {
        return "Base Stage"
    }

    var completedMessage: String {
        return "Completed"
    }

    var status: Bool {
        return false
    }

    var inviteStage: Bool {
        return false
    }

    func setupCompletion(_ value: StageCompletion?) {
        _completion = value
    }

    func execute() {
        print("\tExecute \(name)")
    }

    func setupStage(data: [Any]?) {
        noop()
    }
}
