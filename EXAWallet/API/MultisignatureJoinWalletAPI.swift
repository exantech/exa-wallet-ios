//
// Created by Igor Efremov on 21/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MultisignatureJoinWalletAPI {
    init(resultCallback: MultisignatureWalletAPIResultCallback)
    func joinSharedWallet(_ headers: [String: String]?, payload: APIParam) -> Bool

    var apiBuilder: EXAWalletAPIBuilder { get }
}

class MultisignatureJoinWalletAPIImpl: MultisignatureJoinWalletAPI {
    var apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let endPoint = EXAMultisignatureWalletAPIEndPoint.join_wallet.rawValue

    weak private var _callBack: MultisignatureWalletAPIResultCallback?

    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    func joinSharedWallet(_ headers: [String: String]?, payload: APIParam) -> Bool {
        guard let request = apiBuilder.buildApiRequest(endPoint, headers: headers, payload: payload) else { return false }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    var errString: String
                    if theResponse.statusCode == 409 {
                        errString = "Participant with same device uid already joined"
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.completed(result: "")
                        }

                        return
                    } else {
                        errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: errString)
                    }
                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: "")
                    }
                }
            }
        }.resume()

        return false
    }
}

