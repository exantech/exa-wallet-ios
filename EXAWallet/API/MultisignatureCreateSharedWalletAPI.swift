//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MultisignatureWalletAPI {
    func apiCall()
    func prepare()
}

protocol MultisignatureCreateSharedWalletAPI {
    init(resultCallback: MultisignatureWalletAPIResultCallback)
    func createSharedWallet(_ headers: [String: String]?, payload: APIParam) -> Bool

    var apiBuilder: EXAWalletAPIBuilder { get }
}

class MultisignatureCreateSharedWalletAPIImpl: MultisignatureCreateSharedWalletAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    let createSharedWalletEndPoint = APIMethod.create_wallet

    weak private var _callBack: MultisignatureWalletAPIResultCallback?

    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    func createSharedWallet(_ headers: [String: String]?, payload: APIParam) -> Bool {
        guard let request = apiBuilder.buildApiRequest(createSharedWalletEndPoint.rawValue, headers: headers, payload: payload) else { return false }

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
                    if let data = data {
                        let json = JSON(data)
                        if let invite_code = json["invite_code"].string {
                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.completed(result: invite_code)
                            }
                        }
                    }
                }
            }

        }.resume()

        return false
    }
}
