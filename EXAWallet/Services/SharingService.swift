//
// Created by Igor Efremov on 24/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

final class SharingService {

    func share(_ info: String?) {
        guard let info = info else {
            return
        }
        
        guard let root = root() else {
            return
        }

        let sharingVC = UIActivityViewController(activityItems: [info], applicationActivities: nil)
        root.present(sharingVC, animated: true, completion: nil)
    }
}

private extension SharingService {

    func root() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
