//
//  BalanceTableViewCell.swift
//  EXAWallet
//
//  Created by Igor Efremov on 19/04/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

private enum BalanceCellAppearance  {
    
    case title
    case amount
    
    var font: UIFont {
        switch self {
        case .amount:
            return UIFont.systemFont(ofSize: 12.0)
        case .title:
            return UIFont.systemFont(ofSize: 16.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .amount:
            return UIColor.lightGray
        case .title:
            return UIColor.invertedTitleLabelColor
        }
    }
}

private struct ConstantsSize {
    
    static let imageSide = 39.0
    static let labelHeight = 20.0
    static let commonOffset = 20.0
}

private typealias Appearance = BalanceCellAppearance
private typealias s = ConstantsSize

final class BalanceTableViewCell: UITableViewCell {
    
    override var reuseIdentifier: String {
        get {
            return "BalanceTableViewCellIdentifier"
        }
    }

    private let circle: EXACircleView = {
        let v = EXACircleView(color: UIColor.mainColor, radius: 20)
        return v
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = Appearance.title.font
        lbl.textColor = Appearance.title.textColor
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = Appearance.amount.font
        lbl.textColor = Appearance.amount.textColor
        lbl.textAlignment = .left
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        let cellSubviews = [circle, titleLabel, subtitleLabel]
        contentView.addMultipleSubviews(with: cellSubviews)

        circle.snp.makeConstraints { (make) in
            make.width.equalTo(circle.radius * 2.0)
            make.height.equalTo(circle.radius * 2.0)
            make.top.equalToSuperview().offset(s.commonOffset)
            make.left.equalToSuperview().offset(s.commonOffset)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(s.commonOffset)
            make.height.equalTo(s.labelHeight)
            make.left.equalTo(circle.snp.right).offset(s.commonOffset)
            make.top.equalToSuperview().offset(s.commonOffset)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(s.commonOffset)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(circle.snp.right).offset(s.commonOffset)
        }

        circle.applyLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BalanceTableViewCell {

    func update(with balance: BalanceCrypto) {
        titleLabel.text = balance.type.title
        if let str = balance.amountString {
            subtitleLabel.text = "\(str) \(balance.type.description)"
        }
    }

    func update(withMeta value: WalletMetaInfo) {
        let img: UIImage
        if value.type == .personal {
            img = EXAGraphicsResources.personalWalletImage
        } else {
            img = EXAGraphicsResources.commonWalletImage
        }

        circle.backgroundColor = value.color.value
        circle.hasImgOffset = (value.type == .personal)
        circle.imageView.image = img
        circle.imageView.size = img.size

        titleLabel.text = value.name
        var addInfo = ""
        switch value.type {
            case .shared:
                addInfo = " (\(value.signatures) of \(value.participants))"
            default:
                noop()
        }
        subtitleLabel.text = value.type.description + addInfo
    }
}
