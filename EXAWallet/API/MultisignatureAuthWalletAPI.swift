//
// Created by Igor Efremov on 21/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MultisignatureAuthWalletAPI {
    init(resultCallback: MultisignatureWalletAPIResultCallback)
    func auth(_ payload: APIParam?)
}

class MultisignatureAuthWalletAPIImpl: MultisignatureAuthWalletAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    let openSessionEndPoint = "open_session"

    weak private var _callBack: MultisignatureWalletAPIResultCallback?

    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    func auth(_ payload: APIParam?) {
        guard let request = apiBuilder.buildApiRequest(openSessionEndPoint, payload: payload) else { return }

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

                    err += " (Status Code: \(theResponse.statusCode))"
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: err)
                    }
                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    if let data = data {
                        let data = JSON(data)
                        if let session_id = data["session_id"].string {
                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.completed(result: session_id)
                            }
                        }
                    }
                }
            }
        }.resume()
    }
}

