//
// Created by Igor Efremov on 2019-02-13.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation

class OutputsFSM {
    var scheme: MultisigMachineSchema {
        return _outputsMachineSchema
    }

    private var _outputsMachineSchema = MultisigMachineSchema(initialState: .beginning) { (presentState, trigger) -> MultisignatureWorkflowState in
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
                toState = .outputsSend
            default:
                toState = .finished
            }
        case .outputsSend:
            switch trigger {
            default:
                toState = .outputsGet
            }
        case .outputsGet:
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
