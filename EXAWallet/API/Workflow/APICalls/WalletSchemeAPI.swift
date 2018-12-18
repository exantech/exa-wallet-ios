//
// Created by Igor Efremov on 2019-02-25.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

protocol WalletSchemeAPI {
    func walletScheme(inviteCode: InviteCodeParam)
    func walletScheme(publicKey: PublicKeyParam)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

final class WalletSchemeAPIImpl: WalletSchemeAPI {

    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let walletSchemeEndPointByInviteCode = EXAMultisignatureWalletAPIEndPoint.scheme.rawValue
    private let walletSchemeEndPointByPublicKey = EXAMultisignatureWalletAPIEndPoint.wallet_scheme.rawValue
    weak private var _callBack: WalletSchemeAPIResultCallbackImpl?

    required init(resultCallback: WalletSchemeAPIResultCallbackImpl?) {
        _callBack = resultCallback
    }

    func walletScheme(inviteCode: InviteCodeParam) {
        guard let req = apiBuilder.buildApiRequest(walletSchemeEndPointByInviteCode, method: .get, headers: nil, payload: inviteCode, info: true) else { return }

        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    if 404 == theResponse.statusCode {
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.completed(result: SharedWalletScheme.None)
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
                    let worker = WalletSchemeDataWorker()
                    let scheme = worker.process(data)

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: scheme)
                    }
                }
            }
        }.resume()
    }

    func walletScheme(publicKey: PublicKeyParam) {
        guard let req = apiBuilder.buildApiRequest(walletSchemeEndPointByPublicKey, method: .get, headers: nil, payload: publicKey, info: true) else { return }

        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    if 404 == theResponse.statusCode {
                        DispatchQueue.main.async { [weak self] in
                            self?._callBack?.failure(error: "Not found")
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
                    let worker = WalletSchemeDataWorker()
                    let scheme = worker.process(data)

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: scheme)
                    }
                }
            }
        }.resume()
    }
}
