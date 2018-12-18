//
// Created by Igor Efremov on 2019-03-04.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

protocol WalletPusherAPI {
    func register(_ headers: [String: String], payload: PusherRegisterParam)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

final class WalletPusherAPIImpl: WalletPusherAPI {

    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let pusherRegisterEndPoint = EXAMultisignatureWalletAPIEndPoint.push_register.endPoint
    weak private var _callBack: WalletPusherAPIResultCallbackImpl?

    required init(resultCallback: WalletPusherAPIResultCallbackImpl?) {
        _callBack = resultCallback
    }

    func register(_ headers: [String: String], payload: PusherRegisterParam) {
       guard let request = apiBuilder.buildApiRequest(pusherRegisterEndPoint, headers: headers, payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    if 404 == theResponse.statusCode {
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.completed(result: "Fail")
                        }
                    } else {
                        let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.failure(error: errString)
                        }
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: "Success")
                    }
                }
            }
        }.resume()
    }
}

