//
// Created by Igor Efremov on 04/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol SharedWalletStateWalletAPI {
    func walletState(_ headers: [String: String]?)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

class SharedWalletStateWalletAPIImpl: SharedWalletStateWalletAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let walletStateEndPoint = EXAMultisignatureWalletAPIEndPoint.wallet.rawValue
    weak private var _callBack: SharedWalletStateAPIResultCallbackImpl?

    required init(resultCallback: SharedWalletStateAPIResultCallbackImpl) {
        _callBack = resultCallback
    }

    func walletState(_ headers: [String: String]?) {
        guard let req = buildRequest(walletStateEndPoint, headers: headers) else { return }
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    if 404 == theResponse.statusCode {
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.completed(result: SharedWalletState.None)
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
                    let worker = WalletStateDataWorker()
                    let state = worker.process(data)

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: state)
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
