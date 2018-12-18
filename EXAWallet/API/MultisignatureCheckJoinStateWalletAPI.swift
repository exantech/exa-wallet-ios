//
// Created by Igor Efremov on 24/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol MultisignatureCheckJoinStateWalletAPI {
    func checkMultisigInfo(_ headers: [String: String]?)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

class MultisignatureCheckJoinStateWalletAPIImpl: NSObject, MultisignatureCheckJoinStateWalletAPI, URLSessionDelegate {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let checkJoinedEndPoint: EXAMultisignatureWalletAPIEndPoint

    private let _apiVersion: APIVersion

    weak private var _callBack: SharedWalletAPIResultCheckJoinCallbackImpl?

    required init(resultCallback: SharedWalletAPIResultCheckJoinCallbackImpl, apiVersion: APIVersion) {
        _apiVersion = apiVersion
        switch _apiVersion {
        case .v1:
            checkJoinedEndPoint = EXAMultisignatureWalletAPIEndPoint.multisig
        case .v2:
            checkJoinedEndPoint = EXAMultisignatureWalletAPIEndPoint.multisig_info
        }
        _callBack = resultCallback
    }

    func checkMultisigInfo(_ headers: [String: String]?) {
        guard let req = buildRequest(checkJoinedEndPoint.rawValue, headers: headers) else { return }
        let apiV = _apiVersion

        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: errString)
                    }
                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    let worker = MultisigCheckJoinStateWorker()
                    let infos = worker.process(data, apiVersion: apiV)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: infos)
                    }
                }
            }

        }.resume()
    }

    private func buildRequest(_ endPoint: String, headers: [String: String]?) -> URLRequest? {
        return apiBuilder.buildApiRequest(endPoint, method: .get, headers: headers,
                info: true)
    }
}
