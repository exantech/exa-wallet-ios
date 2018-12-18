//
// Created by Igor Efremov on 11/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class ReceiveAddressQRHeaderView: ReceiveQRHeaderView {

    override func afterCopyAction(_ value: String?) {
#if TEST
        EXACommon.saveTestInfo(value, storageFileName: MoneroCommonConstants.receiveAddressTxt)
#endif
    }
}
