//
// Created by Igor Efremov on 01/02/2019.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation

class EXAInviteCodeWorker {

    func process(inviteCodeValue: String, meta: WalletMetaInfo) -> InviteCode? {
        if let inviteCode = InviteCode(value: inviteCodeValue) {
            debugPrint("Invite code: \(inviteCodeValue)")
            AppState.sharedInstance.setupInviteCode(inviteCode, for: meta.uuid)

            return inviteCode
        }


        return nil
    }
}
