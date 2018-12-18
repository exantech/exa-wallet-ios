//
//  AppBioAuthView.swift
//
//  Created by Vladimir Malakhov on 13/07/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

enum AppBioAuthViewStyle {
    case touch, face
}

final class AppBioAuthView: UIViewController {
    
    var onAccessButtonTapped: DefaultCallback?
    var onSkipButtonTapped: DefaultCallback?
    
    private let bioIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let accessButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        btn.setTitleColor(UIColor.mainColor, for: .normal)
        btn.layer.cornerRadius = 4
        btn.setTitle(l10n(.commonEnable), for: .normal)
        btn.addTarget(self, action: #selector(accessButtonAction), for: .touchUpInside)
        return btn
    }()
    
    private let skipButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(l10n(.commonSkip), for: .normal)
        btn.addTarget(self, action: #selector(skipButtonAction), for: .touchUpInside)
        return btn
    }()
    
    init(_ style: AppBioAuthViewStyle) {
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupAttributes(with: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AppBioAuthView {
    
    func setupView() {
        addSubviews()
        applyLayout()
        applyStyle()
    }
    
    func addSubviews() {
        let subviews = [bioIcon, titleLabel, accessButton, skipButton]
        view.addMultipleSubviews(with: subviews)
    }
    
    func applyLayout() {
        bioIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bioIcon.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        accessButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        skipButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
    }
    
    func applyStyle() {
        view.backgroundColor = UIColor.mainColor
    }
}

private extension AppBioAuthView {
    
    func setupAttributes(with style: AppBioAuthViewStyle) {
        switch style {
        case .touch:
            titleLabel.text = l10n(.auth_bio_touch_message_setup)
            bioIcon.image = #imageLiteral(resourceName: "touch_id")
        case .face:
            titleLabel.text = l10n(.auth_bio_face_message_setup)
            bioIcon.image = #imageLiteral(resourceName: "face_id")
        }
    }
}

private extension AppBioAuthView {
    
    @objc func accessButtonAction() {
        onAccessButtonTapped?()
    }
    
    @objc func skipButtonAction() {
        onSkipButtonTapped?()
    }
}
