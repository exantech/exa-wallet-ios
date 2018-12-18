//
// Created by Igor Efremov on 29/05/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class NonceWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _api: MultisignatureAuthWalletAPI?
    private var _payload: APIParam?
    
    override var status: Bool {
        return false
    }
    
    override var name: String {
        return "Nonce"
    }
    
    override var completedMessage: String {
        return "Got nonce"
    }
    
    override func execute() {
        super.execute()
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else { return }
        
        EXANonceService.shared.getServerNonce(sessionId) { [weak self] (result, nonce) in
            if result == true {
                self?._completion?.onStageCompleted(nil, type: nil)
            } else {
                self?.failure(error: "Error getting nonce")
            }
        }
    }
    
    func failure(error: String) {
        _completion?.onStageSkipped(result: false, reason: error)
    }
    
    func completed(result: String) {
        
    }
    
    func completed(resultArray: [String]) {
        
    }
    
    func completed(stage: MultisigStage) {
        
    }
    
    func completed(resultJSON: JSON) {
        
    }
}
