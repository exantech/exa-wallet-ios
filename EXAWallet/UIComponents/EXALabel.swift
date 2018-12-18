//
//  EXALabel.swift
//  EXAWallet
//
//  Created by Igor Efremov on 23/04/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

//TODO: Разнести палитры для общего пользования и use case
enum LabelPalette {

    case main
    case title
    case note
    case darkMain
    case exchangeTitleLabel
    case warning
    
    case unmarked
    
    var font: UIFont {
        switch self {
        case .main:
            return UIFont.systemFont(ofSize: 16.0)
        case .title:
            return UIFont.boldSystemFont(ofSize: 16.0)
        case .note:
            return UIFont.systemFont(ofSize: 16.0)
        case .darkMain, .warning:
            return UIFont.systemFont(ofSize: 14.0)
        case .exchangeTitleLabel:
            return UIFont.systemFont(ofSize: 20.0, weight: .medium)
        case .unmarked:
            return UIFont.systemFont(ofSize: 17.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .main:
            return UIColor.mainColor
        case .title:
            return UIColor.titleLabelColor
        case .note:
            return UIColor.grayTitleColor
        case .darkMain:
            return UIColor.black
        case .exchangeTitleLabel:
            return UIColor.valueLabelColor
        case .unmarked:
            return UIColor.black
        case .warning:
            return UIColor.localRed
        }
    }
    
    var alignment: NSTextAlignment? {
        switch self {
        case .main, .title, .note, .exchangeTitleLabel, .warning:
            return .center
        case .darkMain, .unmarked:
            return nil
        }
    }
}

final class EXALabel: UILabel {
    
    var style: LabelPalette = .unmarked {
        didSet {
            
            font = style.font
            textColor = style.textColor
            
            if let alignment = style.alignment {
                textAlignment = alignment
            }
        }
    }
}
