//
// Created by Igor Efremov on 06/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

import Alamofire

protocol EXAWalletOutputsChangeAPI {
    func sendOwnOutput(_ headers: [String: String]?, payload: APIParam)
    func getOutputs(_ headers: [String: String]?)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

class EXAWalletOutputsChangeAPIImpl: EXAWalletOutputsChangeAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let sendOwnOutputEndPoint = EXAMultisignatureWalletAPIEndPoint.outputs.rawValue

    weak private var _callBack: MultisignatureWalletAPIResultCallback?

    // TODO in v2
    //private let worker = SecureDataWorker()
    private let worker = OutputsDataWorker()

    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    func getOutputs(_ headers: [String: String]?) {
        guard let request = apiBuilder.buildApiRequest(sendOwnOutputEndPoint, method: .get, headers: headers) else { return }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: errString)
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    let msgs = self.worker.process(data)
                    print(msgs)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(resultArray: msgs)
                    }
                }
            }

        }.resume()
    }

    func sendOwnOutput(_ headers: [String: String]?, payload: APIParam) {
        guard let request = apiBuilder.buildApiRequest(sendOwnOutputEndPoint, headers: headers, payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: errString)
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: "Output accepted")
                    }
                }
            }

        }.resume()
    }
}
