//
// Created by Igor Efremov on 14/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

struct InviteCodeParam: APIParam {
    private var _value: String?

    init(_ value: String) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["invite_code": theValue]
        return params
    }

    func queryString() -> String? {
        guard let theValue = _value else { return nil }
        return "invite_code=\(theValue)"
    }
}

struct SessionIdParam: APIParam {
    private var _value: String?
    
    init(_ value: String) {
        _value = value
    }
    
    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["session_id": theValue]
        return params
    }
    
    func queryString() -> String? {
        guard let theValue = _value else { return nil }
        return "session_id=\(theValue)"
    }
}

struct PusherRegisterParam: APIParam {
    private var _device_uid: String?
    private var _token: String?
    private let _platform = "APNS_DEMO"

    init(deviceUid: String, token: String) {
        _device_uid = deviceUid
        _token = token
    }

    func json() -> JSON? {
        guard let theDeviceUID = _device_uid else { return nil }
        guard let theToken = _token else { return nil }
        let params: JSON? = ["platform": _platform, "device_uid": theDeviceUID, "token": theToken]

        return params
    }
}

struct PublicKeyParam: APIParam {
    private var _value: String?

    init(_ value: String) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["public_key": theValue]
        return params
    }

    func queryString() -> String? {
        guard let theValue = _value else { return nil }
        return "public_key=\(theValue)"
    }
}

struct OpenSessionParam: APIParam {
    private var _value: String?
    private var _userAgent: String?

    init(_ value: String, userAgent: String) {
        _value = value
        _userAgent = userAgent
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        guard let theUserAgent = _userAgent else { return nil }
        let params: JSON? = ["public_key": theValue, "user_agent": theUserAgent]
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct SecureDataParam: APIParam {
    private var _value: Jsonable?

    init(_ value: Jsonable) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value?.json() else { return nil }
        let params: JSON? = ["secure_data": theValue]
        return params
    }
}

struct MultiSigInfoV1Param: APIParam {
    private var _value: String?

    init(_ value: String) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["multisig_info": theValue]
        return params
    }
}

struct MultiSigInfoV2Param: APIParam {
    private var _value: String?

    init(_ value: String) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["multisig_info": theValue]
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct ExtraMultiSigInfoParam: APIParam {
    private var _value: String?

    init(_ value: String) {
        _value = value
    }

    func json() -> JSON? {
        guard let theValue = _value else { return nil }
        let params: JSON? = ["extra_multisig_info": theValue]
        return params
    }
}

struct CreateSharedWalletV1Param: APIParam {
    private var _name: String?
    private var _signers: UInt
    private var _participants: UInt
    private var _multisig_info: String?
    private var _device_uid: String?

    init(_ meta: WalletMetaInfo, multisigInfo: String, deviceUID: String) {
        _name = meta.name
        _signers = meta.signatures
        _participants = meta.participants
        _multisig_info = multisigInfo
        _device_uid = deviceUID
    }

    func json() -> JSON? {
        guard let name = _name else { return nil }
        guard let multisig_info = _multisig_info else { return nil }
        #if NO_DEVICE_UID
            let params: JSON? = ["name": name, "signers": _signers, "participants": _participants,
                             "multisig_info": multisig_info]
        #else
            guard let device_uid = _device_uid else { return nil }
            let params: JSON? = ["name": name, "signers": _signers, "participants": _participants,
                             "multisig_info": multisig_info, "device_uid": device_uid]
        #endif
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct CreateSharedWalletV2Param: APIParam {
    private var _signers: UInt
    private var _participants: UInt
    private let _supported_protocols: [EXAAPISupportedProtocols] = [.PairwiseDH]

    init(_ meta: WalletMetaInfo) {
        _signers = meta.signatures
        _participants = meta.participants
    }

    func json() -> JSON? {
        guard let currentProtocol = _supported_protocols.last else { return nil }
        let params: JSON? = ["supported_protocols" : currentProtocol.rawValue, "signers": _signers, "participants": _participants]

        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct JoinSharedWalletV1Param: APIParam {
    private var _inviteCode: String?
    private var _multisig_info: String?
    private var _device_uid: String?

    init(_ inviteCode: String, multisigInfo: String, deviceUID: String) {
        _inviteCode = inviteCode
        _multisig_info = multisigInfo
        _device_uid = deviceUID
    }

    func json() -> JSON? {
        guard let name = _inviteCode else { return nil }
        guard let multisig_info = _multisig_info else { return nil }
        guard let device_uid = _device_uid else { return nil }
        
        #if NO_DEVICE_UID
            let params: JSON? = ["invite_code": name, "multisig_info": multisig_info]
        #else
            let params: JSON? = ["invite_code": name, "multisig_info": multisig_info, "device_uid": device_uid]
        #endif
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct JoinSharedWalletV2Param: APIParam {
    private var _inviteCode: String?
    private var _publicKey: String?
    private let _supported_protocols: [EXAAPISupportedProtocols] = [.PairwiseDH]

    init(_ inviteCode: String, publicKey: String) {
        _inviteCode = inviteCode
        _publicKey = publicKey
    }

    func json() -> JSON? {
        guard let currentProtocol = _supported_protocols.last else { return nil }
        guard let inviteCode = _inviteCode else { return nil }
        guard let publicKey = _publicKey else { return nil }

        let params: JSON? = ["supported_protocols": currentProtocol.rawValue, "invite_code": inviteCode, "public_key": publicKey]
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct SharedOutputsParam: APIParam {
    private var _outputs: String?

    init(_ outputs: String?) {
        _outputs = outputs
    }

    func json() -> JSON? {
        guard let outputs = _outputs else { return nil }

        let params: JSON? = ["outputs": outputs]
        return params
    }
}

struct TxProposalParam: APIParam {
    private var _destination: String!
    private var _description: String = ""
    private var _signed_transaction: String!
    private var _amount: UInt64 = 0
    private var _fee: UInt64 = 0

    init(_ to: String, _ description: String = "", _ signed_transaction: String, _ amount: UInt64, _ fee: UInt64 = 0) {
        _destination = to
        _description = description
        _signed_transaction = signed_transaction
        _amount = amount
        _fee = fee
    }

    func json() -> JSON? {
        let params: JSON? = ["destination_address": _destination, "description": _description, "signed_transaction": _signed_transaction,
                             "amount": String(_amount), "fee": String(_fee)]
        return params
    }

    func rawString() -> String? {
        return nil
    }
}

struct DecisionParam: APIParam {
    private var _signed_transaction: String?
    private var _approved: Bool = false
    private var _approval_nonce: UInt = 0

    init(_ signed_transaction: String?, _ decision: Bool, _ approval_nonce: UInt) {
        _signed_transaction = signed_transaction
        _approved = decision
        _approval_nonce = approval_nonce
    }

    func json() -> JSON? {
        let params: JSON? = ["signed_transaction": _signed_transaction ?? "", "approved": _approved, "approval_nonce": _approval_nonce]
        return params
    }

    func rawString() -> String? {
        return nil
    }
}
