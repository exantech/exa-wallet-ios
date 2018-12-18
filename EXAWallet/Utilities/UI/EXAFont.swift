//
//  EXAFont.swift
//  EXAWallet
//
//  Created by Igor Efremov on 17/12/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

enum EXAAddressFontType {
    case regular, bold
    
    var fontName: String {
        switch self {
        case .regular:
            return "Menlo-Bold"
        case .bold:
            return "Menlo-Regular"
        }
    }
}

extension UIFont {
    
    static var addressFont: UIFont {
        return addressFont(ofSize: 18.0, type: .regular)
    }
    
    static var specialFont: UIFont {
        return specialFont(ofSize: 18.0)
    }
    
    static func addressFont(ofSize fontSize: CGFloat, type: EXAAddressFontType) -> UIFont {
        return UIFont(name: type.fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    static func specialFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "ShareTechMono-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
