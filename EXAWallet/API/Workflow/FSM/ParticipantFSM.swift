//
// Created by Igor Efremov on 04/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class ParticipantFSM {
    var scheme: MultisigMachineSchema {
        return _scheme
    }

    private var _scheme: MultisigMachineSchema

    init(apiVersion: APIVersion) {
        _scheme = ParticipantFSM.initializeFSM(for: apiVersion)
    }

    private class func initializeFSM(for apiVersion: APIVersion) -> MultisigMachineSchema {
        switch apiVersion {
        case .v1:
            return initializeFSMv1()
        case .v2:
            return initializeFSMv2()
        }
    }

    private class func initializeFSMv1() -> MultisigMachineSchema {
        return MultisigMachineSchema(initialState: .beginning) { (presentState, trigger) -> MultisignatureWorkflowState in
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
                    toState = .join
                default:
                    toState = .finished
                }
            case .join:
                switch trigger {
                case .success:
                    toState = .getMultiSignInfo
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
            case .getExtraMultiSignInfo:
                switch trigger {
                case .success:
                    toState = .finalize
                default:
                    toState = .state
                }
            case .transform:
                switch trigger {
                case .success, .skip:
                    toState = .sendMultiSignInfo
                default:
                    toState = .state
                }
            case .sendMultiSignInfo:
                switch trigger {
                case .success, .skip:
                    toState = .getExtraMultiSignInfo
                default:
                    toState = .state
                }
            case .changePublicKey:
                switch trigger {
                default:
                    toState = .state
                }
            case .finalize:
                switch trigger {
                default:
                    toState = .changePublicKey
                }
            case .state:
                switch trigger {
                case .success, .fail:
                    toState = .state
                case .finish:
                    toState = .finished
                case .skip:
                    toState = .getMultiSignInfo
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

    private class func initializeFSMv2() -> MultisigMachineSchema {
        return MultisigMachineSchema(initialState: .beginning) { (presentState, trigger) -> MultisignatureWorkflowState in
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
                    toState = .state
                default:
                    toState = .finished
                }
            case .join:
                switch trigger {
                default:
                    toState = .state
                }
            case .getMultiSignInfo:
                switch trigger {
                case .success:
                    toState = .transform
                case .skip:
                    toState = .sendMultiSignInfo
                default:
                    toState = .finished
                }
            case .finalize:
                switch trigger {
                case .success:
                    toState = .changePublicKey
                default:
                    toState = .state
                }
            case .changePublicKey:
                switch trigger {
                default:
                    toState = .state
                }
            case .transform:
                switch trigger {
                case .success:
                    toState = .markParticipantReady
                default:
                    toState = .state
                }
            case .markParticipantReady:
                switch trigger {
                default:
                    toState = .finished
                }
            case .state:
                switch trigger {
                case .success:
                    toState = .getMultiSignInfo
                case .skip:
                    toState = .join
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
}
