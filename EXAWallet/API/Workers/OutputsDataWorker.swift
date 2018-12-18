//
// Created by Igor Efremov on 2019-02-22.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class OutputsDataWorker: APIBaseDataWorker<[String]> {

    override func process(_ data: Data?) -> [String] {
        return postProcess(preProcess(data))
    }

    private func preProcess(_ data: Data?) -> [String] {
        let outputsTag = "outputs"
        var outputs = [String]()

        if let data = data {
            let json = JSON(data)
            if let theOutputs = json[outputsTag].array {
                if theOutputs.count > 0 {
                    for n in 0...theOutputs.count-1 {
                        if let info = theOutputs[n].string {
                            outputs.append(info)
                        }
                    }
                }
            }
        }

        return outputs
    }

    private func postProcess(_ data: [String]) -> [String] {
        return data
    }
}
