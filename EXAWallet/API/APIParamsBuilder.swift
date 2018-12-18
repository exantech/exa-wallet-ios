//
// Created by Igor Efremov on 31/01/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

enum APIVersion: String {
    case v1, v2
}

enum APIMethod: String {
    case open_session, create_wallet, join_wallet, multisig_info, nonce
}

class APIParamsBuilder {
    static let shared = APIParamsBuilder()

    func prepareParamsUsingCurrentAPI(method: APIMethod, rawParams: [String: Any]) -> APIParam? {
        return prepareParams(method: method,
                apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion,
                rawParams: rawParams)
    }

    func prepareParams(method: APIMethod, apiVersion: APIVersion, rawParams: [String: Any]) -> APIParam? {
        var param: APIParam? = nil

        switch (method, apiVersion) {
        case (.open_session, .v1) :
            if let theKey = rawParams["key"] as? String {
                param = PublicKeyParam(theKey)
            }
        case (.open_session, .v2) :
            if let theKey = rawParams["key"] as? String, let theUserAgent = rawParams["agent"] as? String {
                param = OpenSessionParam(theKey, userAgent: theUserAgent)
            }
        case (.create_wallet, .v1) :
            if let theMetaInfo = rawParams["meta"] as? WalletMetaInfo, let theMultisigInfo = rawParams["multi"] as? String,
               let theDeviceUID = rawParams["device_uid"] as? String {
                param = CreateSharedWalletV1Param(theMetaInfo, multisigInfo: theMultisigInfo, deviceUID: theDeviceUID)
            }
        case (.create_wallet, .v2) :
            if let theMetaInfo = rawParams["meta"] as? WalletMetaInfo {
                param = CreateSharedWalletV2Param(theMetaInfo)
            }
        case (.join_wallet, .v1) :
            if let theInviteCode = rawParams["invite_code"] as? String, let theMultisigInfo = rawParams["multi"] as? String, let theDeviceUID = rawParams["device_uid"] as? String {
                param = JoinSharedWalletV1Param(theInviteCode, multisigInfo: theMultisigInfo, deviceUID: theDeviceUID)
            }
        case (.join_wallet, .v2) :
            if let theInviteCode = rawParams["invite_code"] as? String, let thePublicKey = rawParams["public_key"] as? String {
                param = JoinSharedWalletV2Param(theInviteCode, publicKey: thePublicKey)
            }
        case (.multisig_info, .v1) :
            if let theValue = rawParams["multi"] as? String {
                param = MultiSigInfoV1Param(theValue)
            }
        default:
            noop()
        }

        return param
    }
}
