//
// Created by Igor Efremov on 07/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class ValidatePassphraseBuilder {

    func prepareForValidate(_ passPhrase: String?) -> ([String]?, [String]?) {
        guard let theString = passPhrase else { return (nil, nil) }
        var words: [String] = theString.split(separator: " ", omittingEmptySubsequences: true).map{String($0)}

        let numMissedWords = EXACommon.random(2) + 3
        var missedIndices: Set<Int> = Set<Int>()

        for _ in 0..<numMissedWords {
            let before = missedIndices.count
            var after = missedIndices.count
            while before == after {
                missedIndices.insert(EXACommon.random(words.count))
                after = missedIndices.count
            }
        }

        var shuffledWords: [String] = [String]()

        for index in missedIndices {
            shuffledWords.append(words[index])
            words[index] = "_______"
        }

        shuffledWords.shuffle()
        return (words, shuffledWords)
    }
}
