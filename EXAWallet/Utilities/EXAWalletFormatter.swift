//
// Created by Igor Efremov on 28/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class SpecialAmountFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .decimal
        groupingSeparator = " "
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class DotSeparatorNumberFormatter: NumberFormatter {
    override init() {
        super.init()
        decimalSeparator = EXACommon.dotSymbol
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class EXAWalletFormatter {
    static let transactionDateFormat = "dd.MM.YYYY HH:mm"
    static let amountFormatter = SpecialAmountFormatter()
    static let dotNumberFormatter = DotSeparatorNumberFormatter()

    class func formattedAmount(_ preformattedAmount: String?) -> String? {
        guard let thePreformattedAmount = preformattedAmount else { return nil }
        let parts = thePreformattedAmount.split(separator: ".", omittingEmptySubsequences: true)
        var result: String = thePreformattedAmount
        if parts.count == 2  {
            var fractPart = parts[1]
            if fractPart.count > 2 {
                while fractPart.hasSuffix("0") && fractPart.count > 2 {
                    fractPart.removeLast()
                }
            }

            result = "\(parts[0]).\(fractPart)"
        }

        return result
    }
}
