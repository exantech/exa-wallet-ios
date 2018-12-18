//
// Created by Igor Efremov on 06/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

import Alamofire

protocol EXAProposalsAPI {
    func sendTxProposal(_ headers: [String: String]?, payload: TxProposalParam)
    func currentTxProposals(_ headers: [String: String]?)
    func proposalDecision(_ decision: Bool, proposalId: String, signedTransaction: String, approvalsNonce: UInt)
    func setupProposalLock(proposalId: String, onSuccess: (() -> Void)?)

    var apiBuilder: EXAWalletAPIBuilder { get }
}

class EXATransactionProposalsAPIImpl: EXAProposalsAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let txProposalEndPoint = EXAMultisignatureWalletAPIEndPoint.tx_proposals.rawValue
    private let txProposalDecisionEndPoint = EXAMultisignatureWalletAPIEndPoint.decision.rawValue

    weak private var _callBack: MultisignatureWalletAPIResultCallback?

    required init(resultCallback: MultisignatureWalletAPIResultCallback) {
        _callBack = resultCallback
    }

    func sendTxProposal(_ headers: [String: String]?, payload: TxProposalParam) {
        guard let request = apiBuilder.buildApiRequest(txProposalEndPoint, headers: headers, payload: payload) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    var err: String = "Error during request"
                    if let data = data {
                        let json = JSON(data)
                        if let error = json["error"].string {
                            err = error

                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.failure(error: err)
                            }

                            return
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: HTTPURLResponse.localizedString(forStatusCode: theResponse.statusCode))
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    if let data = data {
                        let json = JSON(data)
                        if let theTotal = json["total"].int, let theProcessed = json["processed"].int, let theSent  = json["sent"].int  {
                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.completed(result: "Total outputs: \(theTotal), processed: \(theProcessed), sent: \(theSent)")
                            }

                            return
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: "Proposal sent")
                        EXADialogs.showMessage("Proposal created & sent", title: EXAAppInfoService.appTitle, buttonTitle: l10n(.commonOk))
                    }
                }
            }

        }.resume()
    }

    func proposalDecision(_ decision: Bool, proposalId: String, signedTransaction: String, approvalsNonce: UInt) {
        var headers: [String: String]?
        let params = DecisionParam(signedTransaction, decision, approvalsNonce)
        if let theSignature = EXABaseHttpAPI.prepareSignature(payload: params) {
            headers = EXABaseHttpAPI.prepareHeader(with: theSignature)
        }

        guard let request = apiBuilder.buildApiRequest(composeDecisionPath(proposalId: proposalId),
                method: .post, headers: headers, payload: params) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    var err: String = "Error during request"
                    if let data = data {
                        let json = JSON(data)
                        if let error = json["error"].string {
                            err = error

                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.failure(error: err)
                            }

                            return
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: HTTPURLResponse.localizedString(forStatusCode: theResponse.statusCode))
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    if let data = data {
                        let json = JSON(data)
                        if let count = json.array?.count {
                            if count > 0 {
                                DispatchQueue.main.async { [weak self] in
                                    self?._callBack?.completed(resultJSON: json)
                                }
                            }
                        }
                    }
                }
            }
        }.resume()
    }

    func currentTxProposals(_ headers: [String: String]?) {
#if TEST_PROPOSAL
        if let test = EXACommon.loadTestInfo(MoneroCommonConstants.testProposals) {
            let json = JSON(parseJSON: test)
            if let count = json.array?.count {
                DispatchQueue.main.async { [weak self] in
                    self?._callBack?.completed(resultJSON: json)
                }
            }
        }

        return
#endif

        guard let request = apiBuilder.buildApiRequest(txProposalEndPoint, method: .get, headers: headers) else { return }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if 400 <= theResponse.statusCode {
                    var err: String = "Error during request"
                    if let data = data {
                        let json = JSON(data)
                        if let error = json["error"].string {
                            err = error

                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.failure(error: err)
                            }

                            return
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: HTTPURLResponse.localizedString(forStatusCode: theResponse.statusCode))
                    }

                    return
                }

                if 200...299 ~= theResponse.statusCode {
                    if let data = data {
                        let json = JSON(data)

                        // TODO: Check count
                        //if let count = json.array?.count {
                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.completed(resultJSON: json)
                            }
                        //}
                    }
                }
            }
        }.resume()
    }

    func setupProposalLock(proposalId: String, onSuccess: (() -> Void)? = nil) {
        var headers: [String: String]?
        if let theSignature = EXABaseHttpAPI.prepareSignature(payload: nil) {
            headers = EXABaseHttpAPI.prepareHeader(with: theSignature)
        }

        guard let request = apiBuilder.buildApiRequest(composeDecisionPath(proposalId: proposalId),
                method: .head, headers: headers) else { return }

        if let theUrl = request.url, let theHeaders = request.allHTTPHeaderFields {
            Alamofire.request(theUrl, method: .head, headers: theHeaders).response { dataResponse in
                if let theResponse = dataResponse.response {
                    // TODO: Check JSON
                    if EXABaseHttpAPI.success(theResponse) {
                        onSuccess?()
                    }
                }
                else {
                    var err: String = "Error during request"
                    if let data = dataResponse.data {
                        let json = JSON(data)
                        if let error = json["error"].string {
                            err = error

                            DispatchQueue.main.async { [weak self] in
                                self?._callBack?.failure(error: err)
                            }

                            return
                        }
                    }
                }

                debugPrint(dataResponse)
            }
        }
    }

    private func composeDecisionPath(proposalId: String) -> String {
        return txProposalEndPoint + "/" + proposalId + "/" + txProposalDecisionEndPoint
    }
}
