//
// Created by Igor Efremov on 12/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

protocol ProposalActionDelegate: class {
    func approveAction()
    func rejectAction()
}

class TransactionProposalViewCell: EXATableViewCell, ProposalActionDelegate {
    private let identifier = "TransactionProposalViewCell"
    private var _proposal: TransactionProposal?

    weak var actionDelegate: ProposalDecisionDelegate?

    var expanded: Bool = false

    var view: TransactionProposalInfoView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = view else { return }
            contentView.addSubview(view)
        }
    }

    var proposal: TransactionProposal? {
        return _proposal
    }

    init(proposal: TransactionProposal) {
        super.init(style: .default, reuseIdentifier: identifier)
        _proposal = proposal

        let view = TransactionProposalInfoView(proposal: proposal)
        view.actionDelegate = self

        self.view = view
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(view)
    }

    init(view: TransactionProposalInfoView) {
        super.init(style: .default, reuseIdentifier: identifier)
        view.removeFromSuperview()
        self.view = view
        backgroundColor = UIColor.clear
        contentView.addSubview(view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        view?.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: frame.width,
                        height: frame.height))
    }

    func approveAction() {
        guard let theProposal = proposal else { return }
        actionDelegate?.approveProposal(theProposal)
    }

    func rejectAction() {
        if let theProposal = proposal {
            actionDelegate?.rejectProposal(theProposal)
        }
    }
}
