//
//  EXAWalletsListView.swift
//  EXAWallet
//
//  Created by Igor Efremov on 02/08/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

private enum Section: Int {
    
    case balance

    static let all = [balance]
}

private struct Constants {
    
    static let cellHeight: CGFloat = 80.0
}

final class EXAWalletsListView: UITableView {
    weak var actionDelegate: WalletsDashboardActionDelegate?

    var onTapConcreteWallet: ((Int) -> ())?
    
    private(set) var balanceList = [BalanceCrypto(value: nil, amountString: nil, type: .XMR)]
    private(set) var walletMetaList: [WalletMetaInfo]? = nil
    
    init() {
        super.init(frame: .zero, style: .plain)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with balanceList: [BalanceCrypto]) {
        self.balanceList = balanceList
        reloadData()
    }

    func update(withMeta metaInfoList: [WalletMetaInfo]) {
        let sortedMeta = metaInfoList.sorted(by: {$0.addedTimestamp > $1.addedTimestamp })
        self.walletMetaList = sortedMeta
        reloadData()
    }
}

private extension EXAWalletsListView {
    
    func setup() {
        backgroundColor = .white
        dataSource = self
        delegate = self
        
        register(BalanceTableViewCell.self, forCellReuseIdentifier: BalanceTableViewCell().reuseIdentifier)
    }
}

extension EXAWalletsListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.balance.rawValue: return Constants.cellHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.balance.rawValue {
            onTapConcreteWallet?(indexPath.row)
        }
    }
}

extension EXAWalletsListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.balance.rawValue: return walletMetaList?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.balance.rawValue: return makeBalanceCell(indexPath: indexPath) ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

private extension EXAWalletsListView {
    
    func makeBalanceCell(indexPath: IndexPath) -> BalanceTableViewCell? {
        guard let walletMetaCell = dequeueReusableCell(withIdentifier: BalanceTableViewCell().reuseIdentifier, for: indexPath) as? BalanceTableViewCell else {
            return nil
        }
        
        if let currentMetaInfo = walletMetaList?[indexPath.row] {
            walletMetaCell.update(withMeta: currentMetaInfo)
        }
        
        return walletMetaCell
    }
}
