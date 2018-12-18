//
// Created by Igor Efremov on 02/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum MultisignatureWorkflowState: Int {
    case beginning = -1
    case auth = 0
    case nonce = 1
    case create
    case registerpush
    case getMultiSignInfo
    case sendMultiSignInfo
    case getExtraMultiSignInfo
    case finalize
    case changePublicKey
    case markParticipantReady
    case join
    case transform
    case state
    case outputsSend
    case outputsGet
    case finished
}

enum MultisignatureTrigger {
    case success
    case fail
    case skip
    case finish
}

typealias MultisigMachineSchema = SwiftFSMSchema<MultisignatureWorkflowState, MultisignatureTrigger>

class MultisigFSMSchemas {
    var creatorMachineSchema: MultisigMachineSchema {
        return _creatorMachineSchema.scheme
    }

    var participantMachineSchema: MultisigMachineSchema {
        return _participantSchema.scheme
    }

    var checkMachineSchema: MultisigMachineSchema {
        return _creatorMachineSchema.scheme
    }

    var outputsMachineSchema: MultisigMachineSchema {
        return _outputsSchema.scheme
    }

    private let _creatorMachineSchema: CreatorFSM
    private let _participantSchema: ParticipantFSM
    private var _outputsSchema = OutputsFSM()

    init(apiVersion: APIVersion) {
        _creatorMachineSchema = CreatorFSM(apiVersion: apiVersion)
        _participantSchema = ParticipantFSM(apiVersion: apiVersion)
    }

    private var _checkMachineSchema = MultisigMachineSchema(initialState: .beginning) { (presentState, trigger) -> MultisignatureWorkflowState in
        var toState: MultisignatureWorkflowState

        switch presentState {
        case .beginning:
            switch trigger {
            case .success:
                toState = .auth
            default:
                toState = .finished
            }
        case .auth:
            switch trigger {
            case .success, .skip:
                toState = .nonce
            default:
                toState = .finished
            }
        case .nonce:
            switch trigger {
            case .success, .skip:
                toState = .create
            default:
                toState = .finished
            }
        case .create:
            switch trigger {
            case .success:
                toState = .getMultiSignInfo
            default:
                toState = .finished
            }
        case .finalize:
            switch trigger {
            case .success:
                toState = .changePublicKey
            default:
                toState = .getMultiSignInfo
            }
        case .changePublicKey:
            switch trigger {
            default:
                toState = .state
            }
        case .getMultiSignInfo:
            switch trigger {
            case .success:
                toState = .transform
            default:
                toState = .state
            }
        case .transform:
            switch trigger {
            case .success:
                toState = .changePublicKey
            default:
                toState = .state
            }
        case .state:
            switch trigger {
            case .success:
                toState = .finished
            default:
                toState = .finished
            }
        case .finished:
            switch trigger {
            default:
                toState = .finished
            }
        default:
            toState = .finished
        }

        return toState
    }

}
