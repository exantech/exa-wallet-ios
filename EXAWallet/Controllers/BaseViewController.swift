//
// Created by Igor Efremov on 29/03/16.
// Copyright (c) 2016 Exantech. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // prevent view going under the navigation bar
        self.edgesForExtendedLayout = UIRectEdge()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
