//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol MultisignatureWalletWorkflowNotification: class {
    func onUpdate(_ text: String, _ invitePhase: Bool)
    func onUpdate(stage: MultisigStage, result: [Any]?)
    func onFinish()
    func onComplete()
}

protocol MultisignatureWalletWorkflow {
    var notifier: MultisignatureWalletWorkflowNotification? { get set }

    func current()
    func start()
    func next(_ data: [Any]?)
    func prev()
}
