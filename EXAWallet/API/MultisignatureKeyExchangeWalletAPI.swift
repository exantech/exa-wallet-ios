//
// Created by Igor Efremov on 28/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MultisignatureKeyExchangeWalletAPI {
    func changePublicKey(_ headers: [String: String]?, payload: PublicKeyParam)
    func sendExtraMultiSigInfo(_ headers: [String: String]?, level: Int, payload: ExtraMultiSigInfoParam)
    func getExtraMultiSigInfo(_ headers: [String: String]?, level: Int)
    func sendMultiSigInfo(_ headers: [String: String]?, payload: APIParam)
    var apiBuilder: EXAWalletAPIBuilder { get }

    var completionAction: ((String) -> Void)? { get set }
    var failureAction: ((String) -> Void)? { get set }
}

class MultisignatureKeyExchangeWalletAPIImpl: MultisignatureKeyExchangeWalletAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let changeKeyEndPoint = EXAMultisignatureWalletAPIEndPoint.change_public_key.endPoint
    private let sendExtraMultiSigInfoEndPoint = EXAMultisignatureWalletAPIEndPoint.extra_multisig_info.endPoint
    private let extraMultiSigEndPoint = EXAMultisignatureWalletAPIEndPoint.extra_multisig.endPoint
    private let multiSigEndPoint = EXAMultisignatureWalletAPIEndPoint.multisig_info.endPoint

    var completionAction: ((String) -> Void)? = nil
    var failureAction: ((String) -> Void)? = nil

    weak private var _callBack: MultisignatureWalletAPIResultCallback?
    weak private var _callBack2: SendMultiSignInfoAPIResultCallbackImpl?
            //MultisignatureWalletAPIResultCallback?

    //required init(resultCallback: MultisignatureWalletAPIResultCallback) {
    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    required init(resultCallback2: SendMultiSignInfoAPIResultCallbackImpl) {
        _callBack2 = resultCallback2
    }

    required init() {
        print("Init MultisignatureKeyExchangeWalletAPIImpl")
    }

    func changePublicKey(_ headers: [String: String]?, payload: PublicKeyParam) {
        guard let request = apiBuilder.buildApiRequest(changeKeyEndPoint, headers: headers, payload: payload) else { return }
        performRequest(request)
    }

    func sendExtraMultiSigInfo(_ headers: [String: String]?, level: Int, payload: ExtraMultiSigInfoParam) {
        let concreteSendExtraMultiSigInfoEndPoint = "\(sendExtraMultiSigInfoEndPoint)" + "/" + "\(level)"
        guard let request = apiBuilder.buildApiRequest(concreteSendExtraMultiSigInfoEndPoint, headers: headers, payload: payload) else { return }
        performRequest(request)
    }

    func performRequest(_ request: URLRequest) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?.failureAction?(errString)
                    }
                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?.completionAction?("Success")
                    }
                }
            }

        }.resume()
    }

    func getExtraMultiSigInfo(_ headers: [String: String]?, level: Int) {
        let concreteExtraMultiSigEndPoint = "\(extraMultiSigEndPoint)" + "/" + "\(level)"
        guard let request = apiBuilder.buildApiRequest(concreteExtraMultiSigEndPoint, method: .get, headers: headers, info: true) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    var err: String = "Error during request"
                    if let data = data {
                        let json = JSON(data)
                        if let error = json["error"].string {
                            err = error
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: err)
                    }
                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    if let data = data {
                        let json = JSON(data)
                        if let theJSONOutputs = json["extra_multisig_infos"].array {
                            let extra_multisig_infos = theJSONOutputs.compactMap{$0["extra_multisig_info"].stringValue}
                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.completed(resultArray: extra_multisig_infos)
                            }

                            return
                        }
                    }
                }
            }

        }.resume()
    }

    func sendMultiSigInfo(_ headers: [String: String]?, payload: APIParam) {
        guard let request = apiBuilder.buildApiRequest(multiSigEndPoint, method: .post, headers: headers, payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack2?.failure(error: errString)
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack2?.completed(result: "Successfully sent own miltisig info")
                    }
                }
            }

        }.resume()
    }
}
