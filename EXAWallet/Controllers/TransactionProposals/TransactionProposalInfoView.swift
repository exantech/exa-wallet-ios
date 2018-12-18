//
// Created by Igor Efremov on 12/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionProposalInfoView: UIView {
    private let imageView: UIImageView = UIImageView(image: nil)
    private let dateLabel = UILabel()
    private let sideImageWidth = EXAGraphicsResources.transactionType(.sent).size.width
    private var descriptionLabel: EXALabel = {
        let lbl = EXALabel()
        lbl.lineBreakMode = .byTruncatingMiddle
        lbl.textAlignment = .left
        return lbl
    }()
    
    private var amountLabel: AmountTransactionLabel?
    private var infoLabel: EXALabel = EXALabel("", textColor: UIColor.mainColor, font: UIFont.systemFont(ofSize: 12.0))

    private var toAddressLabel: EXALabel = EXALabel("To: ", textColor: UIColor.exaBlack, font: UIFont.systemFont(ofSize: 12.0))
    
    private var detailsTextLabel: EXALabel = EXALabel("Description: ", textColor: UIColor.exaBlack, font: UIFont.systemFont(ofSize: 12.0))
    
    private let approveButton: EXAButton = EXAButton(with: l10n(.proposalApprove), height: 30)
    private let rejectButton: EXAButton = EXAButton(with: l10n(.proposalReject), height: 30)

    weak var actionDelegate: ProposalActionDelegate?

    convenience init(proposal: TransactionProposal) {
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.size = CGSize(width: 250, height: 50)

        imageView.image = EXAGraphicsResources.proposalInProcess
    
        dateLabel.font = UIFont.systemFont(ofSize: 11.0)
        dateLabel.textColor = UIColor.grayTitleColor
        dateLabel.textAlignment = .right

        toAddressLabel.numberOfLines = 4
        detailsTextLabel.numberOfLines = 0

        rejectButton.style = .hollow

        approveButton.addTarget(self, action: #selector(onTapApprove), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(onTapReject), for: .touchUpInside)

        var amountString: String = "unknown"
        if let wallet = AppState.sharedInstance.currentWallet {
            amountString = wallet.formatAmount(proposal.amount)
        }

        if proposal.alreadySigned {
            infoLabel.text = "Already signed by you"
            infoLabel.textColor = UIColor.mainColor
        } else {
            if let meta = AppState.sharedInstance.currentWalletInfo {
                infoLabel.text = "Signed by \(proposal.approvalsCount) of \(meta.metaInfo.participants)"
                infoLabel.textColor = UIColor.grayTitleColor
            } else {
                infoLabel.text = ""
            }
        }

        if proposal.approved {
            infoLabel.text = "Approved"
            infoLabel.textColor = UIColor.mainColor
        }

        if proposal.rejected {
            infoLabel.text = "Rejected"
            infoLabel.textColor = UIColor.mainColor
            imageView.image = EXAGraphicsResources.proposalRejected
        }
        
        imageView.size = imageView.image!.size

        approveButton.isHidden = proposal.completedForMe
        rejectButton.isHidden = proposal.completedForMe

        infoLabel.sizeToText()

        amountLabel = AmountTransactionLabel(amountString, ticker: proposal.ticker)
        addMultipleSubviews(with: [imageView, descriptionLabel, detailsTextLabel, amountLabel, dateLabel, infoLabel, toAddressLabel, approveButton, rejectButton])

        descriptionLabel.text = proposal.description
        descriptionLabel.sizeToText()
        descriptionLabel.width = 120

        toAddressLabel.text = "To: " + proposal.to
        toAddressLabel.textAlignment = .left
        
        detailsTextLabel.text = "Description:\n" + proposal.description
        detailsTextLabel.textAlignment = .left

        dateLabel.text = proposal.date
        dateLabel.sizeToText()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        let sideOffset: CGFloat = 20
        let topOffset: CGFloat = 40

        imageView.origin = CGPoint(x: sideOffset, y: topOffset - imageView.size.height / 2)

        descriptionLabel.origin = CGPoint(x: imageView.right + sideOffset, y: sideOffset - 4)

        if let theAmountLabel = amountLabel {
            theAmountLabel.right = sideOffset
            theAmountLabel.top = descriptionLabel.top - 6
        }

        infoLabel.origin = CGPoint(x: imageView.right + sideOffset, y: sideOffset - 7.5 + 23)
        infoLabel.top = ceil(descriptionLabel.bottom + 4)

        dateLabel.right = sideOffset
        dateLabel.bottom = infoLabel.bottom

        toAddressLabel.origin = CGPoint(x: imageView.left, y: infoLabel.bottom + 30)
        toAddressLabel.width = self.size.width - imageView.left * 2
        toAddressLabel.height = 60
        
        detailsTextLabel.origin = CGPoint(x: imageView.left, y: toAddressLabel.bottom + 4)
        detailsTextLabel.width = self.size.width - imageView.left * 2
        detailsTextLabel.height = 72

        approveButton.origin = CGPoint(x: imageView.left, y: detailsTextLabel.bottom + 10)
        approveButton.size = CGSize(width: (self.size.width - imageView.left * 2) / 2 - sideOffset, height: 30)

        rejectButton.size = CGSize(width: (self.size.width - imageView.left * 2) / 2 - sideOffset, height: 30)
        rejectButton.right = sideOffset
        rejectButton.top = approveButton.top
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onTapApprove() {
        actionDelegate?.approveAction()
    }

    @objc func onTapReject() {
        actionDelegate?.rejectAction()
    }
}
