//
// Created by Igor Efremov on 27/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol TransactionsHistoryActionDelegate: class {
    func onSelectTransaction(_ index: Int)
    func onSelectProposals(_ index: Int)
}

enum TransactionsSection: Int {
    case proposals, transactions

    var description: String {
        switch self {
            case .proposals:
                return l10n(.walletHomeProposals)
            case .transactions:
                return l10n(.walletHomeTransactions)
        }
    }
}

class TransactionsHistoryView: UIView, UITableViewDataSource {
    static let heightForHeader: CGFloat = 60.0
    static let heightForRow: CGFloat = 80.0

    let tableView: UITableView = UITableView(frame: CGRect.zero)
    weak var actionDelegate: TransactionsHistoryActionDelegate?
    weak var proposalActionDelegate: ProposalDecisionDelegate?

    private var walletType: WalletType = .personal

    weak var viewModel: TransactionsViewModel? {
        didSet {
            tableView.reloadData()
        }
    }

    var expandedIds: [String: Bool] = [String: Bool]()

    convenience init(walletType: WalletType) {
        self.init(frame: CGRect.zero)
        self.walletType = walletType
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    func initControl() {
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self

        addSubview(tableView)

        applyStyles()
    }

    func applyStyles() {
        tableView.applyStyles()
    }

    func applySizes() {
        tableView.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let number: Int

        switch walletType {
        case .personal:
            number = 1
        case .shared:
            number = existProposals() ? 2 : 1
        }

        return number
    }

    private func existProposals() -> Bool {
        return AppState.sharedInstance.activeProposal.count > 0
    }

    private func sectionType(by index: Int) -> TransactionsSection? {
        switch walletType {
        case .personal:
            return .transactions
        case .shared:
            if existProposals() {
                return TransactionsSection(rawValue: index)
            } else {
                return .transactions
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = sectionType(by: section) {
            switch currentSection {
                case .proposals:
                    return AppState.sharedInstance.activeProposal.count
                case .transactions:
                    guard let model = viewModel?.model else {
                        return 0
                    }
                    return model.count
            }
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sectionType(by: indexPath.section) == TransactionsSection.transactions {
            if let theItem = viewModel?.model?.item(indexPath.row) {
                return TransactionViewCell(transaction: theItem)
            }
        } else {
            let tp = AppState.sharedInstance.activeProposal[indexPath.row]
            let cell = TransactionProposalViewCell(proposal: tp)
            cell.actionDelegate = proposalActionDelegate
            if let theIdentifier = tp.identifier {
                cell.expanded = expandedIds[theIdentifier] ?? false
            }

            return cell
        }

        return UITableViewCell()
    }

    func reloadNeeded() {
        tableView.reloadData()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension TransactionsHistoryView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if sectionType(by: indexPath.section) == .proposals {
           let proposal = AppState.sharedInstance.activeProposal[indexPath.row]
           let value = expandedIds[proposal.identifier!] ?? false
           if value {
               return TransactionsHistoryView.heightForRow * 4
           }
       }

        return TransactionsHistoryView.heightForRow
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionType(by: indexPath.section) == TransactionsSection.transactions {
            actionDelegate?.onSelectTransaction(indexPath.row)
        } else {
            //actionDelegate?.onSelectProposals(indexPath.row)
            if let c = tableView.cellForRow(at: indexPath) as? TransactionProposalViewCell {
                c.expanded = !c.expanded
                if let theProposalId = c.proposal?.identifier {
                    expandedIds[theProposalId] = c.expanded
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransactionsHistoryView.heightForHeader
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = sectionType(by: section) {
            let hv = EXATableHeaderView(width: tableView.bounds.size.width, title: currentSection.description,
                    color: UIColor.headerColor, textColor: UIColor.exaBlack)
            hv.applyLayout()

            return hv
        }

        return nil
    }
}
