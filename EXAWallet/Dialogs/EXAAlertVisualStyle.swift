//
//  EXAAlertVisualStyle.swift
//  EXAWallet
//
//  Created by Igor Efremov on 02/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SDCAlertView

class EXAAlertVisualStyle: AlertVisualStyle {
    override init(alertStyle: AlertControllerStyle) {
        super.init(alertStyle: alertStyle)
        self.normalTextColor = UIColor.mainColor
    }
}

class EXAInputDialogVisualStyle: AlertVisualStyle {
    override init(alertStyle: AlertControllerStyle) {
        super.init(alertStyle: alertStyle)
        self.normalTextColor = UIColor.mainColor
        self.backgroundColor = UIColor.rgb(0xffffff)
        self.textFieldBorderColor = UIColor.clear
    }
}

class EXAActionSheetVisualStyle: AlertVisualStyle {
    override init(alertStyle: AlertControllerStyle) {
        super.init(alertStyle: alertStyle)
        self.normalTextColor = UIColor.exaBlack
        self.backgroundColor = UIColor.rgb(0xffffff)
        self.destructiveTextColor = UIColor.mainColor
        self.textFieldBorderColor = UIColor.clear
    }
}
