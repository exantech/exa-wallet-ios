//
// Created by Igor Efremov on 08/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class PassphrasePreValidator {

    func validate(_ string: String?) -> Bool {
        guard let theString = string else { return false }
        let words: [String] = theString.split(separator: " ", omittingEmptySubsequences: true).map{String($0)}
        return words.count == 25
    }
}
