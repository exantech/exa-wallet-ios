//
// Created by Igor Efremov on 22/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum CryptoTicker: Int, Codable {
    case XMR = 0

    var description: String {
        switch self {
        case .XMR: return "XMR"
        }
    }

    var title: String {
        switch self {
        case .XMR: return "Monero"
        }
    }

    var imageName: String {
        switch self {
        case .XMR: return "monero.png"
        }
    }
}

class CryptoCurrency {
    private var _title: String
    private var _ticker: CryptoTicker
    private var _decimals: UInt8

    static let XMR = CryptoCurrency(ticker: .XMR, decimals: 12)

    var title: String {
        return _title
    }

    var ticker: CryptoTicker {
        return _ticker
    }

    var decimals: UInt8 {
        return _decimals
    }

    init(ticker: CryptoTicker, decimals: UInt8) {
        print("Init \(ticker)")

        _title = ticker.title
        _ticker = ticker
        _decimals = decimals
    }
}
