//
// Created by Igor Efremov on 01/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class MultisigCheckJoinStateWorker {

    func process(_ data: Data?, apiVersion: APIVersion) -> [String] {
        let worker: APIBaseDataWorker<[String]>

        switch apiVersion {
        case .v1:
            worker = MultisigDataWorker()
        case .v2:
            worker = SecureDataWorker()
        }

        return worker.process(data)
    }
}
