//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol TransactionDetailsActionDelegate: class {
    func showCurrentTxInBlockchain()
    func copyToClipboard(_ value: String?)
}

class TransactionDetailsViewController: BaseViewController {
    private let transactionsView: TransactionDetailsView = TransactionDetailsView()
    private var _transaction: Transaction?

    convenience init(_ transaction: Transaction) {
        self.init(nibName: nil, bundle: nil)
        _transaction = transaction
        navigationItem.title = _transaction?.type.description
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [transactionsView].compactMap{$0}.forEach{view.addSubview($0)}
        transactionsView.actionDelegate = self
        transactionsView.viewModel = _transaction

        applyStyles()
        applySizes()
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.detailsBackgroundColor
        transactionsView.applyStyles()
    }

    func applySizes() {
        guard let theTransactionInfo = _transaction else { return }
        let h = max(CGFloat(TransactionAttribute.orderedList.filter{theTransactionInfo.txAttribute(by: $0) != nil}.map{$0.height}.reduce(122, +)), view.height)
        transactionsView.snp.makeConstraints { (make) in
            make.top.left.width.equalToSuperview()
            make.height.equalTo(h)
        }

        transactionsView.applySizes()
    }
}

extension TransactionDetailsViewController: TransactionDetailsActionDelegate {

    func showCurrentTxInBlockchain() {
        guard let theTransaction = _transaction else { return }
        let txUrl = "\(EXAAppInfoService.txInfoServiceBaseUrl)\(theTransaction.txHash)"
        guard let url = URL(string: txUrl) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func copyToClipboard(_ value: String?) {
        guard let theValue = value else { return }
        EXAAppUtils.copy(toClipboard: theValue)
    }
}
