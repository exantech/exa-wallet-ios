//
// Created by Igor Efremov on 07/07/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

extension UITableView: EXAUIStylesSupport {
    func hideEmptySeparators() {
        let emptyFooterView: UIView = UIView(frame: CGRect.zero)
        emptyFooterView.backgroundColor = UIColor.clear
        self.tableFooterView = emptyFooterView
    }

    func applyStyles() {
        self.hideEmptySeparators()
        self.separatorColor = UIColor.rgb(0x000000)
        self.separatorStyle = .singleLine
    }
}
