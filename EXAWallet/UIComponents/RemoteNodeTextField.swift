//
// Created by Igor Efremov on 2019-03-28.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import UIKit

class RemoteNodeTextField: EXAHeaderTextFieldView {

     convenience init() {
        self.init(l10n(.enterRemoteNodeAddress), header: l10n(.remoteNode))
        textField.text = AppState.sharedInstance.settings.environment.nodes.defaultNode
        textField.returnKeyType = .next
        textField.isEnabled = false
    }

    override init(_ placeholder: String, header: String,
                  textColor: UIColor = UIColor.titleLabelColor, placeHolderColor: UIColor = UIColor.placeholderDarkColor) {
        super.init(placeholder, header: header)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
