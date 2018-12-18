//
// Created by Igor Efremov on 23/01/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import UIKit

class EXATabBarItem: UITabBarItem {

    convenience init(image: UIImage?, tag: Int) {
        self.init(title: "", image: image, tag: tag)
        imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }

}
