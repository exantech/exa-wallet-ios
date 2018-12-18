//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum MultisignatureWorkflowType: String {
    case create, join, check, outputs
}

class MultisignatureWalletWorkflowCoordinator: MultisignatureWalletWorkflow, StageCompletion {
    private var _currentStageIndex: Int = 0
    //private var _stages: [MultisignatureWalletWorkflowStage]!

    weak var notifier: MultisignatureWalletWorkflowNotification?

    private var _type: MultisignatureWorkflowType!

    private var multisigMachine: SwiftFSM<MultisigMachineSchema>?
    private var _prevStageData: [Any]? = nil

    private var _currStage: BaseMultisignatureWalletWorkflowStage?


    func current() {

    }

    init(_ type: MultisignatureWorkflowType) {
        _type = type
    }

    func createStage(by workflowState: MultisignatureWorkflowState) -> BaseMultisignatureWalletWorkflowStage? {
        let s: BaseMultisignatureWalletWorkflowStage?
        switch workflowState {
        case .auth:
            s = AuthWorkflowStage()
        case .nonce:
            s = NonceWorkflowStage()
        case .create:
            s = EXACreateSharedWalletWorkflowStage()
        case .registerpush:
            s = EXAPusherStage()
        case .getMultiSignInfo:
            s = EXAMultisigInfoWorkflowStage()
        case .sendMultiSignInfo:
            s = SendExtraMultiSignInfoWorkflowStage()
        case .getExtraMultiSignInfo:
            s = EXAExtraMultiSigInfoWorkflowStage()
        case .finalize:
            s = EXAWalletFinalizeWorkflowStage()
        case .changePublicKey:
            s = EXAChangeKeySharedWalletWorkflowStage()
        case .join:
            s = EXAJoinSharedWalletWorkflowStage()
        case .transform:
            s = EXATransformIntoSharedWalletWorkflowStage()
        case .markParticipantReady:
            s = EXAWalletMarkParticipantReadyWorkflowStage()
        case .state:
            s = EXAWalletStateWorkflowStage()
        case .outputsSend:
            s = EXAWalletOutputsChangeStage(mode: .update)
        case .outputsGet:
            s = EXAWalletOutputsChangeStage(mode: .get)
        case .beginning, .finished:
            s = nil
        }

        s?.setupCompletion(self)
        return s
    }

    private func preloadScheme() {
        let apiVersion = ConfigurationSelector.shared.currentConfiguration.apiVersion
        let schemas = MultisigFSMSchemas(apiVersion: apiVersion)
        if _type == .create {
            multisigMachine = SwiftFSM(schema: schemas.creatorMachineSchema)
        } else if _type == .join {
            multisigMachine = SwiftFSM(schema: schemas.participantMachineSchema)
        } else if _type == .check {
            multisigMachine = SwiftFSM(schema: schemas.checkMachineSchema)
        } else if _type == .outputs {
            multisigMachine = SwiftFSM(schema: schemas.outputsMachineSchema)
        }

        multisigMachine?.logging = .logging({(log: String) -> () in
            print(log) //Use any logging method you choose in this closure
        })

        multisigMachine?.machineDidTransitState = { (_ fromState: MultisignatureWorkflowState, _ trigger: MultisignatureTrigger, _ toState: MultisignatureWorkflowState) -> () in
            let currentStage = self.executionStage(by: toState)
            currentStage?.setupStage(data: self._prevStageData)
            currentStage?.execute()
            if toState == .finished {
                self.finish()
            }
        }

    }

    func executionStage(by state: MultisignatureWorkflowState) -> MultisignatureWalletWorkflowStage? {
        _currStage = createStage(by: state)
        return _currStage
    }

    func start() {
        preloadScheme()
        multisigMachine?.trigger(MultisignatureTrigger.success)
    }

    func next(_ data: [Any]? = nil) {
        print("CALL next")
    }

    func finish(_ stage: MultisigStage? = nil) {
        print("Finish Workflow")
        notifier?.onFinish()
    }

    func onStageCompleted(_ info: String?, type: MultisigStage?) {
        print("onStageCompleted")

        if type == .create_wallet {
            notifier?.onUpdate(info ?? "", true)
        }

        _prevStageData = nil
        multisigMachine?.trigger(MultisignatureTrigger.success)
    }

    func onStageCompleted(_ inviteCode: InviteCode, type: MultisigStage?) {
        print("onStageCompleted: \(inviteCode)")

        notifier?.onUpdate(inviteCode.value, true)
        _prevStageData = nil
        multisigMachine?.trigger(MultisignatureTrigger.success)
    }

    func onStageCompleted(result: [Any]?, type: MultisigStage?) {
        _prevStageData = result
        multisigMachine?.trigger(MultisignatureTrigger.success)
    }

    func onStageSkipped(result: Bool, reason: String?) {
        //notifier?.onUpdate(reason ?? "", false)
        /*if result {
            next()
        } else {
            finish()
        }*/

        _prevStageData = nil
        multisigMachine?.trigger(MultisignatureTrigger.skip)
    }

    func onFinishWorkflow() {
        notifier?.onComplete()
        multisigMachine?.trigger(MultisignatureTrigger.finish)
    }

    func prev() {

    }
}
