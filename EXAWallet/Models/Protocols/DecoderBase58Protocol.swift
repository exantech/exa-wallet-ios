//
// Created by Igor Efremov on 20/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol DecoderBase58Protocol {
    func decodeBase58(_ encodedString: String) -> String?
}
