//
// Created by Igor Efremov on 2019-02-20.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol APIDataWorkerProvider {
    associatedtype T
    func process(_ data: Data?) -> T
}

class APIBaseDataWorker <R>: APIDataWorkerProvider {
    typealias T = R
    func process(_ data: Data?) -> T {
        return [] as! T // instead empty implementation
    }
}

class MultisigDataWorker: APIBaseDataWorker<[String]> {

    override func process(_ data: Data?) -> [String] {
        return postProcess(preProcess(data))
    }

    private func preProcess(_ data: Data?) -> [String] {
        let multisigInfosTag = "multisig_infos"
        let multisigInfoTag = "multisig_info"
        var infos = [String]()

        if let data = data {
            let json = JSON(data)
            if let theMultisigInfos = json[multisigInfosTag].array {
                if theMultisigInfos.count > 0 {
                    for n in 0...theMultisigInfos.count-1 {
                        if let info = theMultisigInfos[n][multisigInfoTag].string {
                            infos.append(info)
                        }
                    }

                    let msg = "Got Multisig Infos (\(infos.count)): \(infos.description)"
                    print(msg)
                }
            }
        }

        return infos
    }

    private func postProcess(_ data: [String]) -> [String] {
        return data
    }
}
