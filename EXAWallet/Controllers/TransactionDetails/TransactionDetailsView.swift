//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionDetailsView: EXAView, UITableViewDataSource {
    private let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    weak var actionDelegate: TransactionDetailsActionDelegate?

    weak var viewModel: TransactionAttributesList? {
        didSet {
            tableView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    override func initControl() {
        super.initControl()
        tableView.dataSource = self
        tableView.delegate = self

        addSubview(tableView)

        applyStyles()
    }

    func applyStyles() {
        tableView.applyStyles()
        tableView.backgroundColor = UIColor.clear
    }

    func applySizes() {
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.width.height.equalToSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notEmptyAttributesCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let theModel = viewModel else { return UITableViewCell() }

        let cell = TransactionAttributeViewCell(attributeList: theModel, attribute: theModel.attribute(by: indexPath.row), actionDelegate: actionDelegate)
        return cell
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension TransactionDetailsView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let theModel = viewModel else { return 0.0 }
        let attr = theModel.attribute(by: indexPath.row)
        return CGFloat(attr.height)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 122.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hv = AmountHeaderView(width: tableView.bounds.size.width, title: viewModel?.txAttribute(by: TransactionAttribute.amount),
                color: UIColor.headerColor, textColor: UIColor.exaBlack)
        hv.applyLayout()

        return hv
    }
}
