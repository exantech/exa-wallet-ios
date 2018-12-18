//
// Created by Igor Efremov on 14/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXANonceService {
    static let shared = EXANonceService()
    private var _nonce: AtomicNonce = AtomicNonce(value: 0)
    
    private let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    
    func getServerNonce(_ sessionId: String, completion: ((Bool, UInt64) -> Void)? = nil) {
        guard let request = apiBuilder.buildApiRequest(APIMethod.nonce.rawValue,
                                                       method: .get, payload: SessionIdParam(sessionId), info: true) else {
            completion?(false, 0)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    DispatchQueue.main.async {
                        completion?(false, 0)
                    }
                    return
                }
                
                if EXABaseHttpAPI.success(theResponse) {
                    if let data = data {
                        let json = JSON(data)
                        if let nonce = json["nonce"].uInt64 {
                            DispatchQueue.main.async { [weak self] in
                                self?.setupInitialNonce(nonce: nonce)
                                completion?(true, nonce)
                            }
                        }
                    }
                }
            }
        }.resume()
    }

    func nonceAndIncrement() -> UInt64 {
        return _nonce.incrementAndGet()
    }

    var currentNonce: UInt64 {
        return _nonce.value
    }
    
    private func setupInitialNonce(nonce: UInt64) {
        print("Initial nonce is \(nonce)")
        _nonce.value = nonce
    }
}

extension EXANonceService {
    
    func approvalNonce(for proposal: TransactionProposal) -> UInt {
        return proposal.approvalsCount
    }
}
