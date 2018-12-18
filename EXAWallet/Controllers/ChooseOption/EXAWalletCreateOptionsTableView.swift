//
// Created by Igor Efremov on 03/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

protocol EXAWalletCreateOptionsActionDelegate: class {
    func onSelectCreateOption(_ option: EXAMoneroWalletCreateOption)
}

class EXAWalletCreateOptionsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    weak var actionDelegate: EXAWalletCreateOptionsActionDelegate? = nil
    var blockRepeatTap: Bool = false

    convenience init() {
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.separatorColor = UIColor.screenBackgroundColor

        self.dataSource = self
        self.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EXAMoneroWalletCreateOption.all.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = EXAMoneroWalletCreateOption.all[indexPath.row]
        let cell = CreateOptionsTableViewCell(option: option)
        cell.applyLayout()

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.height / CGFloat(EXAMoneroWalletCreateOption.all.count)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delay(0.25, closure: { [weak self] in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.actionDelegate?.onSelectCreateOption(EXAMoneroWalletCreateOption.all[indexPath.row])
        })
    }
}
