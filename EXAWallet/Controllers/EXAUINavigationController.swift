//
// Created by Igor Efremov on 29/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class EXAUINavigationController: UINavigationController {
    convenience init(_ rootViewController: UIViewController) {
        self.init(rootViewController: rootViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
}

